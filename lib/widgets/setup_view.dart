import 'package:flutter/material.dart';
import '../app_state_manager.dart';
import 'active_todo_widget.dart';

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
          const SizedBox(height: 8),
          const Text(
            '选择专注时长开始任务',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text("单位：分钟"),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: AppStateManager.presetDurations.map((minutes) {
              return ElevatedButton(
                onPressed: () =>
                    appStateManager.timerManager.startTimer(minutes),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
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
          const SizedBox(height: 30),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 20),
          ActiveTodoWidget(todoManager: appStateManager.todoManager),
        ],
      ),
    );
  }
}
