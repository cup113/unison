import 'package:flutter/material.dart';
import 'app_state_manager.dart';
import 'active_todo_view.dart';

class TimerView extends StatelessWidget {
  final AppStateManager appStateManager;
  final int selectedDuration;
  final int remainingSeconds;
  final bool isPaused;
  final int exitCount;
  final VoidCallback onTimerComplete;

  const TimerView({
    super.key,
    required this.appStateManager,
    required this.selectedDuration,
    required this.remainingSeconds,
    required this.isPaused,
    required this.exitCount,
    required this.onTimerComplete,
  });

  @override
  Widget build(BuildContext context) {
    final timerManager = appStateManager.timerManager;
    final todoManager = appStateManager.todoManager;

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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                '退出: $exitCount, 暂停: ${timerManager.pauseCount}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              // 中间的倒计时和进度条
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 圆形进度条
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ),
                      // 中心倒计时文本
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(selectedDuration * 60 - remainingSeconds) ~/ 60}/${selectedDuration}分钟',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isPaused ? '继续' : '暂停'),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: timerManager.cancelTimer,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 20),
              ActiveTodoView(todoManager: todoManager),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
