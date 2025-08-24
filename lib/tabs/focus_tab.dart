import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/todo_manager_interface.dart';
import '../widgets/todo_list_widget.dart';

import '../widgets/setup_view.dart';
import '../widgets/timer_view.dart';
import '../providers.dart';

class FocusTab extends ConsumerStatefulWidget {
  const FocusTab({super.key});

  @override
  ConsumerState<FocusTab> createState() => _FocusTabState();
}

class _FocusTabState extends ConsumerState<FocusTab> {
  @override
  void initState() {
    super.initState();
    // No need for manual listener management with Riverpod
  }

  void _showTimerCompleteDialog() {
    final timerManager = ref.watch(timerManagerProvider);
    final todoManager = ref.watch(todoManagerProvider);
    final activeTodo = todoManager.getActiveTodo(includeCompleted: true);
    int actualDuration = (timerManager.selectedDuration ?? 0) -
        (timerManager.remainingSeconds ?? 0) ~/ 60;

    // 提升控制器和状态管理到外部
    final durationController =
        TextEditingController(text: actualDuration.toString());
    final durationNotifier = ValueNotifier<int>(actualDuration);
    final progressNotifier = ValueNotifier<int>(activeTodo?.progress ?? 0);

    showDialog(
      context: context,
      barrierDismissible: false,
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
                      _buildDurationInput(durationController, durationNotifier),
                      const SizedBox(height: 8),
                      _buildProgressSlider(progressNotifier, activeTodo.total),
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
                      durationNotifier.value,
                      progressNotifier.value,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    timerManager.cancelTimer(true);
                  },
                  child: const Text('确认'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      durationController.dispose();
      durationNotifier.dispose();
      progressNotifier.dispose();
    });
  }

  Widget _buildDurationInput(
    TextEditingController controller,
    ValueNotifier<int> durationNotifier,
  ) {
    return Row(
      children: [
        const Text('实际专注时间:'),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: controller,
            decoration: const InputDecoration(
              suffixText: '分钟',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final parsedValue = int.tryParse(value) ?? durationNotifier.value;
              durationNotifier.value = parsedValue;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSlider(
      ValueNotifier<int> progressNotifier, int maxProgress) {
    return ValueListenableBuilder<int>(
      valueListenable: progressNotifier,
      builder: (context, value, child) {
        return Row(
          children: [
            const Text('任务进度:'),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: maxProgress.toDouble(),
                divisions: maxProgress,
                label: value.toString(),
                onChanged: (newValue) {
                  progressNotifier.value = newValue.toInt();
                },
              ),
            ),
            Text('$value/$maxProgress'),
          ],
        );
      },
    );
  }

  Future<void> _handleTimerCompletion(
    Todo? activeTodo,
    int actualDuration,
    int adjustedDuration,
    int adjustedProgress,
  ) async {
    final timerManager = ref.read(timerManagerProvider);
    final todoManager = ref.read(todoManagerProvider);
    final appStateManager = ref.read(appStateManagerProvider);

    // 更新TODO的进度和专注时间
    if (activeTodo != null) {
      await todoManager.setProgress(activeTodo.id, adjustedProgress);
      await todoManager.addFocusedTime(
        activeTodo.id,
        adjustedDuration,
      );
    }

    // 使用AppStateManager保存专注记录
    if (timerManager.startTime != null &&
        timerManager.selectedDuration != null) {
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

      await appStateManager.saveFocusRecord(
        startTime: timerManager.startTime!,
        endTime: endTime,
        plannedDuration: timerManager.selectedDuration!,
        actualDuration: adjustedDuration,
        pauseCount: timerManager.pauseCount,
        exitCount: timerManager.exitCount,
        isCompleted: true, // 完成的计时器标记为已完成
        todos: todos.isNotEmpty ? todos : null,
        progressList: progressList.isNotEmpty ? progressList : null,
        focusedTimeList: focusedTimeList.isNotEmpty ? focusedTimeList : null,
      );
    }
  }

  void _showTodoList(BuildContext context, TodoManagerInterface todoManager) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('任务列表'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: TodoListWidget(
            onTodoChanged: () => setState(() {}),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerManager = ref.watch(timerManagerProvider);
    final todoManager = ref.watch(todoManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('专注'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _showTodoList(context, todoManager),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: Center(
          key: ValueKey<String>(
              timerManager.remainingSeconds == null ? 'setup' : 'timer'),
          child: timerManager.remainingSeconds == null
              ? const SetupView()
              : TimerView(
                  selectedDuration: timerManager.selectedDuration!,
                  remainingSeconds: timerManager.remainingSeconds!,
                  isPaused: timerManager.isPaused,
                  exitCount: timerManager.exitCount,
                  onTimerComplete: _showTimerCompleteDialog,
                ),
        ),
      ),
    );
  }
}
