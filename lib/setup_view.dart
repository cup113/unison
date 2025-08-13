import 'package:flutter/material.dart';
import 'todo_manager.dart';
import 'timer_manager.dart';

class ActiveTodoView extends StatelessWidget {
  final TodoManager todoManager;

  const ActiveTodoView({super.key, required this.todoManager});

  @override
  Widget build(BuildContext context) {
    // 使用 includeCompleted: true 来显示已完成但仍然活动的任务
    final activeTodo = todoManager.getActiveTodo(includeCompleted: true);
    if (activeTodo == null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '当前没有选中任务',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: const Text(
                '请在右上角的任务列表中选择一个任务作为当前专注任务',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('当前任务:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  activeTodo.isCompleted ? Colors.grey[300] : Colors.green[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: activeTodo.isCompleted ? Colors.grey : Colors.green,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activeTodo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: activeTodo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    if (activeTodo.isCompleted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '已完成',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (activeTodo.category.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '类别: ${activeTodo.category}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (activeTodo.estimatedTime > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '预计时间: ${activeTodo.estimatedTime}分钟',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('进度:'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: activeTodo.progress.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: activeTodo.progress.toString(),
                        onChanged: (value) {
                          todoManager.setProgress(activeTodo.id, value.toInt());
                        },
                      ),
                    ),
                    Text('${activeTodo.progress}/10'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
        const SizedBox(height: 20),
        ActiveTodoView(todoManager: todoManager),
      ],
    );
  }
}
