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

    // 添加监听器以重建UI
    _timerManager.addListener(() {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      }
    });

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
    int actualDuration = (_timerManager.selectedDuration ?? 0) -
        (_timerManager.remainingSeconds ?? 0) ~/ 60;

    // 在这里定义状态变量，确保它们在整个对话框中保持一致
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
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('恭喜你完成专注任务！'),
                    const SizedBox(height: 16),
                    if (activeTodo != null) ...[
                      Text('任务: ${activeTodo.title}'),
                      const SizedBox(height: 8),
                      _buildDurationInput((value) {
                        setState(() {
                          adjustedDuration = value;
                        });
                      }, adjustedDuration),
                      const SizedBox(height: 8),
                      _buildProgressSlider((value) {
                        setState(() {
                          adjustedProgress = value;
                        });
                      }, adjustedProgress),
                    ] else
                      const Text('未选择任务'),
                  ],
                ),
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
                    _timerManager.cancelTimer(true);
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

  Widget _buildDurationInput(Function(int) onChanged, int adjustedDuration) {
    return Row(
      children: [
        const Text('实际专注时间:'),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: TextField(
            keyboardType: TextInputType.number,
            controller:
                TextEditingController(text: adjustedDuration.toString()),
            decoration: const InputDecoration(
              suffixText: '分钟',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final parsedValue = int.tryParse(value) ?? adjustedDuration;
              onChanged(parsedValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSlider(Function(int) onChanged, int adjustedProgress) {
    // 确保值在有效范围内
    double sliderValue = adjustedProgress.toDouble();
    sliderValue = sliderValue.clamp(0.0, 10.0);

    return Row(
      children: [
        const Text('任务进度:'),
        const SizedBox(width: 8),
        Expanded(
          child: Slider(
            value: sliderValue,
            min: 0,
            max: 10,
            divisions: 10,
            label: adjustedProgress.toString(),
            onChanged: (value) {
              onChanged(value.toInt());
            },
          ),
        ),
        Text('$adjustedProgress/10'),
      ],
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

    // 使用AppStateManager保存专注记录
    if (_timerManager.startTime != null &&
        _timerManager.selectedDuration != null) {
      final endTime = DateTime.now();

      // 收集需要保存的todo数据
      List<Todo> todos = [];
      List<int> progressList = [];
      List<int> focusedTimeList = [];

      if (activeTodo != null) {
        todos.add(activeTodo);
        progressList.add(adjustedProgress);
        focusedTimeList.add(adjustedDuration);
      }

      await _appStateManager.saveFocusRecord(
        startTime: _timerManager.startTime!,
        endTime: endTime,
        plannedDuration: _timerManager.selectedDuration!,
        actualDuration: adjustedDuration,
        pauseCount: _timerManager.pauseCount,
        exitCount: _timerManager.exitCount,
        isCompleted: true, // 完成的计时器标记为已完成
        todos: todos.isNotEmpty ? todos : null,
        progressList: progressList.isNotEmpty ? progressList : null,
        focusedTimeList: focusedTimeList.isNotEmpty ? focusedTimeList : null,
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
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: Center(
            // 修改这里：使用更明确的key来区分两种状态
            key: ValueKey<String>(
                _timerManager.remainingSeconds == null ? 'setup' : 'timer'),
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
      ),
    );
  }

  void _showStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsPage(appStateManager: _appStateManager),
      ),
    );
  }

  void _showTodoList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('任务列表'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: TodoListWidget(
            todoManager: _todoManager,
            onTodoChanged: () => setState(() {}),
          ),
        ),
      ),
    );
  }
}
