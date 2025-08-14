import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'todo.dart';
import 'todo_manager.dart';
import 'todo_list_widget.dart';
import 'timer_manager.dart';
import 'setup_view.dart';
import 'timer_view.dart';
import 'statistics_page.dart';
import 'app_state_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unison',
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
  late final AppStateManager _appStateManager;
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

    // 初始化 AppStateManager
    _appStateManager = AppStateManager(
      timerManager: _timerManager,
      todoManager: _todoManager,
    );

    WidgetsBinding.instance.addObserver(this);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appStateManager.dispose();
    _timerManager.dispose();
    super.dispose();
  }

  void _showTimerCompleteDialog() {
    final activeTodo = _todoManager.getActiveTodo(includeCompleted: true);
    int actualDuration = _timerManager.selectedDuration ?? 0;
    int adjustedProgress = activeTodo?.progress ?? 0;
    int adjustedDuration = actualDuration;

    showDialog(
      context: context,
      barrierDismissible: false, // 用户必须确认对话框
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('专注完成'),
              content: _buildDialogContent(
                activeTodo,
                actualDuration,
                adjustedProgress,
                adjustedDuration,
                setState,
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _handleTimerCompletion(
                      activeTodo,
                      actualDuration,
                      adjustedDuration,
                      adjustedProgress,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    _timerManager.cancelTimer();
                  },
                  child: const Text('确认'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogContent(
    Todo? activeTodo,
    int actualDuration,
    int adjustedProgress,
    int adjustedDuration,
    StateSetter setState,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('恭喜你完成专注任务！'),
          const SizedBox(height: 16),
          if (activeTodo != null) ...[
            Text('任务: ${activeTodo.title}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('实际专注时间:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: adjustedDuration,
                  items: List.generate(
                    11, // 最多可增加10分钟
                    (index) => DropdownMenuItem(
                      value: actualDuration + index,
                      child: Text('${actualDuration + index} 分钟'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      adjustedDuration = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('任务进度:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: adjustedProgress.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: adjustedProgress.toString(),
                    onChanged: (value) {
                      setState(() {
                        adjustedProgress = value.toInt();
                      });
                    },
                  ),
                ),
                Text('$adjustedProgress/10'),
              ],
            ),
          ] else
            const Text('未选择任务'),
        ],
      ),
    );
  }

  Future<void> _handleTimerCompletion(
    Todo? activeTodo,
    int actualDuration,
    int adjustedDuration,
    int adjustedProgress,
  ) async {
    // 更新TODO的进度和专注时间
    if (activeTodo != null) {
      _todoManager.setProgress(activeTodo.id, adjustedProgress);
      _todoManager.addFocusedTime(
        activeTodo.id,
        adjustedDuration,
      );
    }

    // 保存专注记录
    if (_timerManager.startTime != null &&
        _timerManager.selectedDuration != null) {
      final endTime = DateTime.now();
      await _timerManager.saveFocusRecord(
        startTime: _timerManager.startTime!,
        endTime: endTime,
        plannedDuration: _timerManager.selectedDuration!,
        actualDuration: adjustedDuration,
        pauseCount: _timerManager.pauseCount,
        exitCount: _timerManager.exitCount,
        todoId: activeTodo?.id,
        todoTitle: activeTodo?.title,
        todoProgress: adjustedProgress,
        todoFocusedTime: adjustedDuration,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      if (_timerManager.remainingSeconds != null &&
          _timerManager.remainingSeconds! > 0) {
        _timerManager.handleAppExit();
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
          title: const Text('Unison 专注计时器'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: _showStatistics,
            ),
            IconButton(icon: const Icon(Icons.list), onPressed: _showTodoList),
          ],
        ),
        body: Center(
          child: _timerManager.remainingSeconds == null
              ? SetupView(
                  appStateManager: _appStateManager,
                )
              : TimerView(
                  appStateManager: _appStateManager,
                  selectedDuration: _timerManager.selectedDuration!,
                  remainingSeconds: _timerManager.remainingSeconds!,
                  isPaused: _timerManager.isPaused,
                  exitCount: _timerManager.exitCount,
                  onTimerComplete: _showTimerCompleteDialog,
                ),
        ),
      ),
    );
  }

  void _showStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsPage(timerManager: _timerManager),
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
              // 增大Drawer的高度
              constraints: const BoxConstraints(maxHeight: 600),
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
