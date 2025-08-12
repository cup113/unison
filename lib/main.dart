import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'todo_manager.dart';
import 'todo_list_widget.dart';
import 'timer_manager.dart';
import 'active_todo_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Co-Progress',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const FocusTimerPage(),
    );
  }
}

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage>
    with WidgetsBindingObserver {
  late final TimerManager _timerManager;
  final TodoManager _todoManager = TodoManager();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initManagers();
  }

  Future<void> _initManagers() async {
    _timerManager = TimerManager();
    await _todoManager.loadFromStorage();
    await _timerManager.loadFromStorage();

    WidgetsBinding.instance.addObserver(this);
    _todoManager.addListener(_handleTodoChange);
    _timerManager.addListener(_handleTimerChange);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timerManager.dispose();
    _todoManager.removeListener(_handleTodoChange);
    super.dispose();
  }

  void _handleTodoChange() {
    setState(() {});
  }

  void _handleTimerChange() {
    setState(() {});
  }

  void _showTimerCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('专注完成'),
          content: const Text('恭喜你完成专注任务！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _timerManager.cancelTimer();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      if (_timerManager.remainingSeconds != null &&
          _timerManager.remainingSeconds! > 0) {
        _timerManager.incrementExitCount();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }

        // 不再在返回时增加退出计数
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Co-Progress 专注计时器'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(icon: const Icon(Icons.list), onPressed: _showTodoList),
          ],
        ),
        body: Center(
          child: _timerManager.remainingSeconds == null
              ? SetupView(
                  timerManager: _timerManager,
                  exitCount: _timerManager.exitCount,
                  todoManager: _todoManager,
                )
              : TimerView(
                  timerManager: _timerManager,
                  selectedDuration: _timerManager.selectedDuration!,
                  remainingSeconds: _timerManager.remainingSeconds!,
                  isPaused: _timerManager.isPaused,
                  exitCount: _timerManager.exitCount,
                  todoManager: _todoManager,
                  onTimerComplete: _showTimerCompleteDialog,
                ),
        ),
      ),
    );
  }

  void _showTodoList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              constraints: const BoxConstraints(maxHeight: 500),
              child: TodoListWidget(
                todoManager: _todoManager,
                onTodoChanged: () => setState(() {}),
              ),
            );
          },
        );
      },
    );
  }
}

class SetupView extends StatelessWidget {
  final TimerManager timerManager;
  final int exitCount;
  final TodoManager todoManager;

  const SetupView({
    super.key,
    required this.timerManager,
    required this.exitCount,
    required this.todoManager,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '选择专注时长',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: TimerManager.presetDurations.map((minutes) {
            return ElevatedButton(
              onPressed: () => timerManager.startTimer(minutes),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: Text('$minutes分钟'),
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        Text(
          '退出次数: $exitCount',
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
        const SizedBox(height: 20),
        ActiveTodoView(todoManager: todoManager),
      ],
    );
  }
}

class TimerView extends StatelessWidget {
  final TimerManager timerManager;
  final int selectedDuration;
  final int remainingSeconds;
  final bool isPaused;
  final int exitCount;
  final TodoManager todoManager;
  final VoidCallback onTimerComplete;

  const TimerView({
    super.key,
    required this.timerManager,
    required this.selectedDuration,
    required this.remainingSeconds,
    required this.isPaused,
    required this.exitCount,
    required this.todoManager,
    required this.onTimerComplete,
  });

  @override
  Widget build(BuildContext context) {
    // 检查计时器是否完成
    if (remainingSeconds <= 0 && timerManager.isTimerActive == false) {
      // 延迟调用完成回调，确保UI更新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onTimerComplete();
      });
    }

    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (timerManager.isTimerActive) {
                  timerManager.pauseTimer();
                } else {
                  timerManager.resumeTimer();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(isPaused ? '继续' : '暂停'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: timerManager.cancelTimer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('取消'),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          '$selectedDuration分钟专注中...',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Text(
          '退出次数: $exitCount',
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
        const SizedBox(height: 20),
        ActiveTodoView(todoManager: todoManager),
      ],
    );
  }
}
