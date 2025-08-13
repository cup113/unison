import 'package:flutter/material.dart';
import 'timer_manager.dart';
import 'todo_manager.dart';
import 'active_todo_view.dart';

class TimerView extends StatelessWidget {
  final TimerManager timerManager;
  final int selectedDuration;
  final int remainingSeconds;
  final bool isPaused;
  final int exitCount;
  final TodoManager todoManager;
  final VoidCallback onTimerComplete;

  const TimerView({
    super.key,
    required this.timerManager,
    required this.selectedDuration,
    required this.remainingSeconds,
    required this.isPaused,
    required this.exitCount,
    required this.todoManager,
    required this.onTimerComplete,
  });

  @override
  Widget build(BuildContext context) {
    // 检查计时器是否完成
    if (remainingSeconds <= 0 && timerManager.isTimerActive == false) {
      // 延迟调用完成回调，确保UI更新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onTimerComplete();
      });
    }

    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;
    final progress = 1.0 - (remainingSeconds / (selectedDuration * 60));

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 顶部信息
            const SizedBox(height: 40),
            Text(
              '$selectedDuration分钟专注中...',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              '退出次数: $exitCount, 暂停次数: ${timerManager.pauseCount}',
              style: const TextStyle(fontSize: 16, color: Colors.orange),
            ),

            // 中间的倒计时和进度条
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 圆形进度条
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                    // 中心倒计时文本
                    Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 底部控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (timerManager.isTimerActive) {
                      timerManager.pauseTimer();
                    } else {
                      timerManager.resumeTimer();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(isPaused ? '继续' : '暂停'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: timerManager.cancelTimer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('取消'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ActiveTodoView(todoManager: todoManager),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }
}
