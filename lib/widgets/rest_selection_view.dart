import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../constants/app_constants.dart';

class RestSelectionView extends ConsumerWidget {
  const RestSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerManager = ref.watch(timerManagerProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '恭喜完成专注！选择休息时长（单位：分钟）',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: AppConstants.restDurations.map((minutes) {
                return ElevatedButton(
                  onPressed: () {
                    timerManager.startTimer(minutes);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[100],
                    foregroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  child: Text('$minutes'),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                timerManager.skipRest();
              },
              child: const Text('跳过休息，继续专注'),
            ),
          ],
        ),
      ),
    );
  }
}
