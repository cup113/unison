import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nanoid2/nanoid2.dart';
import '../models/todo.dart';
import '../models/focus.dart';
import '../services/todo_manager_interface.dart';
import '../providers.dart';

import '../widgets/rest_timer_view.dart';
import '../widgets/todo_list_widget.dart';
import '../widgets/setup_view.dart';
import '../widgets/rest_selection_view.dart';
import '../widgets/timer_view.dart';

class FocusTab extends ConsumerStatefulWidget {
  const FocusTab({super.key});

  @override
  ConsumerState<FocusTab> createState() => _FocusTabState();
}

class _FocusTabState extends ConsumerState<FocusTab> {
  final Map<String, int> _initialTodoProgress = {};
  final Map<String, int> _finalTodoProgress = {};
  final Set<String> _modifiedTodoIds = {}; // TODO data persistence
  late final TodoManagerInterface _todoManager;

  @override
  void initState() {
    super.initState();
    _setupProgressTracking();
  }

  void _setupProgressTracking() {
    _todoManager = ref.read(todoManagerProvider);

    // Capture initial progress state for all todos
    for (final todo in _todoManager.todos) {
      _initialTodoProgress[todo.id] = todo.progress;
      _finalTodoProgress[todo.id] = todo.progress;
    }

    // Listen for progress changes during the session
    _todoManager.addListener(_onTodoProgressChanged);
  }

  void _onTodoProgressChanged() {
    final todoManager = ref.read(todoManagerProvider);

    // Update final progress state and track modified todos
    for (final todo in todoManager.todos) {
      final currentProgress = todo.progress;
      // Todo can be created during the session
      final initialProgress = _initialTodoProgress[todo.id] ?? 0;

      if (currentProgress != initialProgress) {
        _finalTodoProgress[todo.id] = currentProgress;
        _modifiedTodoIds.add(todo.id);
      }
    }
  }

  void _showTimerCompleteDialog() {
    final timerManager = ref.watch(timerManagerProvider);
    final todoManager = ref.watch(todoManagerProvider);
    final activeTodo = todoManager.getActiveTodo();

    // Get all modified todos during the session
    final modifiedTodos = todoManager.todos
        .where((todo) => _modifiedTodoIds.contains(todo.id))
        .toList();

    int actualDuration = (timerManager.selectedDuration ?? 0) -
        (timerManager.remainingSeconds ?? 0) ~/ 60;

    final durationController =
        TextEditingController(text: actualDuration.toString());
    final durationNotifier = ValueNotifier<int>(actualDuration);
    final progressNotifier = ValueNotifier<int>(activeTodo?.progress ?? 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                  Text('最后专注的任务: ${activeTodo.title}'),
                  const SizedBox(height: 8),
                  _buildDurationInput(durationController, durationNotifier),
                  const SizedBox(height: 8),
                  _buildProgressSlider(progressNotifier, activeTodo.total),
                ],
                if (modifiedTodos.isNotEmpty) ...[
                  ...modifiedTodos.map((todo) => _buildTodoProgressSection(
                        todo,
                        _initialTodoProgress[todo.id] ?? 0,
                        _finalTodoProgress[todo.id] ?? 0,
                      )),
                ] else
                  const Text('本次专注期间没有任务进度变化'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _handleTimerCompletion(actualDuration, activeTodo,
                    durationNotifier.value, progressNotifier.value);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                timerManager.cancelTimer(true);
                _cleanupProgressTracking();
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodoProgressSection(
      Todo todo, int initialProgress, int finalProgress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('任务: ${todo.title}'),
        Text('进度变化: $initialProgress → $finalProgress'),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _handleTimerCompletion(
    int actualDuration,
    Todo? activeTodo,
    int lastAdjustedDuration,
    int lastAdjustedProgress,
  ) async {
    final timerManager = ref.read(timerManagerProvider);
    final todoManager = ref.read(todoManagerProvider);
    final focusId = nanoid();

    if (activeTodo != null) {
      await todoManager.setProgress(activeTodo.id, lastAdjustedProgress);
      await todoManager.addFocusedTime(
        activeTodo.id,
        lastAdjustedDuration,
      );
    }

    // Collect all modified todos with their progress changes
    final focusTodos = todoManager.todos
        .where((todo) => _modifiedTodoIds.contains(todo.id))
        .map((todo) => FocusTodo(
            id: nanoid(),
            todoId: todo.id,
            focusId: focusId,
            duration: actualDuration, // TODO change
            progressStart: _initialTodoProgress[todo.id]!,
            progressEnd: _finalTodoProgress[todo.id]!,
            todoTitle: todo.title,
            todoCategory: todo.category))
        .toList();

    // Save focus record with all modified todos
    if (timerManager.startTime != null &&
        timerManager.selectedDuration != null) {
      await timerManager.saveFocusRecord(
        startTime: timerManager.startTime!,
        endTime: DateTime.now(),
        plannedDuration: timerManager.selectedDuration!,
        actualDuration: actualDuration,
        pauseCount: timerManager.pauseCount,
        exitCount: timerManager.exitCount,
        isCompleted: true,
        focusId: focusId,
        todoData: focusTodos,
      );
    }
  }

  void _cleanupProgressTracking() {
    _initialTodoProgress.clear();
    _finalTodoProgress.clear();
    _modifiedTodoIds.clear();
    _todoManager.removeListener(_onTodoProgressChanged);
  }

  @override
  void dispose() {
    _cleanupProgressTracking();
    super.dispose();
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

  (String, Widget) _buildView() {
    final timerManager = ref.watch(timerManagerProvider);
    if (timerManager.remainingSeconds == null) {
      if (timerManager.isRest) {
        return ('setup', RestSelectionView());
      } else {
        return ('rest-selection', SetupView());
      }
    } else {
      if (timerManager.isRest) {
        return ('timer-rest', RestTimerView());
      } else {
        return (
          'timer',
          TimerView(
            selectedDuration: timerManager.selectedDuration!,
            remainingSeconds: timerManager.remainingSeconds!,
            isPaused: timerManager.isPaused,
            exitCount: timerManager.exitCount,
            onTimerComplete: _showTimerCompleteDialog,
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoManager = ref.watch(todoManagerProvider);
    final (key, view) = _buildView();

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
          key: ValueKey<String>(key),
          child: view,
        ),
      ),
    );
  }
}
