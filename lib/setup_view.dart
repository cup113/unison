import 'package:flutter/material.dart';
import 'todo_manager.dart';
import 'timer_manager.dart';
import 'active_todo_view.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '专注计时器',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            '选择专注时长开始任务',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: TimerManager.presetDurations.map((minutes) {
              return ElevatedButton(
                onPressed: () => timerManager.startTimer(minutes),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('$minutes分钟'),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 20),
          const Text(
            '当前任务',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ActiveTodoView(todoManager: todoManager),
        ],
      ),
    );
  }
}
