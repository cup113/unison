import 'package:flutter/material.dart';
import 'package:unison/todo.dart';
import 'package:unison/timer_manager.dart';
import 'app_state_manager.dart';
import 'active_todo_view.dart';

class TimerView extends StatefulWidget {
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
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  @override
  void initState() {
    super.initState();
    // 添加监听器以更新UI
    widget.appStateManager.addListener(_updateUI);
  }

  @override
  void dispose() {
    widget.appStateManager.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final timerManager = widget.appStateManager.timerManager;
    final todoManager = widget.appStateManager.todoManager;
    final Todo? activeTodo = todoManager.getActiveTodo();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildStatusInfo(timerManager),
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: _buildTimerDisplay(),
                ),
              ),
              _buildAddTimeButtons(timerManager),
              _buildTimerControls(timerManager, activeTodo),
              const SizedBox(height: 20),
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

  Widget _buildStatusInfo(timerManager) {
    return Text(
      '退出: ${widget.exitCount}, 暂停: ${timerManager.pauseCount}',
      style: const TextStyle(fontSize: 16, color: Colors.grey),
    );
  }

  Widget _buildTimerDisplay() {
    // 统一处理时间计算，包括负数情况
    final totalSeconds = widget.remainingSeconds.abs();
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    final isNegative = widget.remainingSeconds < 0;

    // 简化进度计算逻辑
    final progress = widget.remainingSeconds >= 0
        ? 1.0 - (widget.remainingSeconds / (widget.selectedDuration * 60))
        : 1.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 圆形进度条
        _buildCircularProgress(progress),
        // 中心倒计时文本
        _buildTimerText(minutes, seconds, isNegative),
      ],
    );
  }

  Widget _buildCircularProgress(double progress) {
    return SizedBox(
      width: 250,
      height: 250,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0,
          end: progress,
        ),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return CircularProgressIndicator(
            value: value,
            strokeWidth: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          );
        },
      ),
    );
  }

  Widget _buildTimerText(int minutes, int seconds, bool isNegative) {
    final timeString =
        '${isNegative ? '-' : ''}${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final elapsedMinutes =
        ((widget.selectedDuration * 60 - widget.remainingSeconds) ~/ 60).abs();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timeString,
          key: ValueKey(timeString),
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.redAccent : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$elapsedMinutes/${widget.selectedDuration} 分钟',
          style: TextStyle(
            fontSize: 18,
            color: isNegative ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAddTimeButtons(TimerManager timerManager) {
    if (widget.remainingSeconds >= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [1, 5, 15]
              .map(
                (minutes) => Row(
                  children: [
                    _buildAddTimeButton(timerManager, minutes),
                    if (minutes != 15) const SizedBox(width: 10),
                  ],
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAddTimeButton(TimerManager timerManager, int minutes) {
    return ElevatedButton(
      onPressed: () {
        timerManager.addTime(minutes);
        if (!timerManager.isTimerActive && timerManager.isPaused) {
          timerManager.resumeTimer();
        }
      },
      child: Text('+$minutes分钟'),
    );
  }

  Widget _buildTimerControls(TimerManager timerManager, Todo? activeTodo) {
    final bool canComplete =
        widget.remainingSeconds <= widget.selectedDuration * 60 ~/ 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPauseResumeButton(timerManager),
            const SizedBox(width: 20),
            _buildCancelButton(timerManager),
            const SizedBox(width: 20),
            _buildCompleteButton(timerManager, canComplete),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPauseResumeButton(TimerManager timerManager) {
    return ElevatedButton(
      onPressed: () {
        if (timerManager.isTimerActive) {
          timerManager.pauseTimer();
        } else {
          timerManager.resumeTimer();
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        animationDuration: const Duration(milliseconds: 200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            timerManager.isTimerActive ? Icons.pause : Icons.play_arrow,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(timerManager) {
    return OutlinedButton(
      onPressed: () {
        // 计算已计时时间（分钟）
        final elapsedMinutes =
            (widget.selectedDuration * 60 - widget.remainingSeconds) ~/ 60;

        // 显示确认对话框
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('确认取消'),
              content: Text(elapsedMinutes < 1
                  ? '计时不足1分钟，此次计时将不会被记录。确定要取消吗？'
                  : '确定要取消当前计时吗？'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 关闭对话框
                  },
                  child: const Text('继续计时'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 关闭对话框
                    timerManager.cancelTimer(false);
                    // 添加取消操作的反馈
                    if (context is Element) {
                      final scaffold =
                          context.findAncestorWidgetOfExactType<Scaffold>();
                      if (scaffold != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('计时器已取消'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('确认取消'),
                ),
              ],
            );
          },
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(width: 2, color: Colors.red),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel, size: 24, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(TimerManager timerManager, bool canComplete) {
    return ElevatedButton(
      onPressed: canComplete
          ? () {
              widget.onTimerComplete();
            }
          : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        animationDuration: const Duration(milliseconds: 200),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 24),
        ],
      ),
    );
  }
}
