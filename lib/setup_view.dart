import 'package:flutter/material.dart';
import 'app_state_manager.dart';
import 'active_todo_view.dart';

class SetupView extends StatelessWidget {
  final AppStateManager appStateManager;

  const SetupView({
    super.key,
    required this.appStateManager,
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
            '选择专注时长（分钟）开始任务',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: AppStateManager.presetDurations.map((minutes) {
              return ElevatedButton(
                onPressed: () =>
                    appStateManager.timerManager.startTimer(minutes),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(minutes.toString()),
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
          ActiveTodoView(todoManager: appStateManager.todoManager),
        ],
      ),
    );
  }
}
