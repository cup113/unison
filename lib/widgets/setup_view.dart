import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'active_todo_widget.dart';
import '../providers.dart';
import '../constants/app_constants.dart';

class SetupView extends ConsumerWidget {
  const SetupView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            children: AppConstants.presetDurations.map((minutes) {
              return ElevatedButton(
                onPressed: () {
                  final timerManager = ref.read(timerManagerProvider);
                  timerManager.startTimer(minutes);
                },
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
          const ActiveTodoWidget(),
        ],
      ),
    );
  }
}
