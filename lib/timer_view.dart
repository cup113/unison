import 'package:flutter/material.dart';
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

    // 检查计时器是否完成
    if (widget.remainingSeconds <= 0 && timerManager.isTimerActive == false) {
      // 延迟调用完成回调，确保UI更新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTimerComplete();
      });
    }

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
              _buildTimerControls(timerManager),
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
    final minutes = (widget.remainingSeconds / 60).floor();
    final seconds = widget.remainingSeconds % 60;
    final progress =
        1.0 - (widget.remainingSeconds / (widget.selectedDuration * 60));

    return Stack(
      alignment: Alignment.center,
      children: [
        // 圆形进度条
        _buildCircularProgress(progress),
        // 中心倒计时文本
        _buildTimerText(minutes, seconds),
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
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return CircularProgressIndicator(
            value: value,
            strokeWidth: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              value < 0.3
                  ? Colors.red
                  : value < 0.7
                      ? Colors.orange
                      : Colors.green,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerText(int minutes, int seconds) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          key: ValueKey(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'),
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(widget.selectedDuration * 60 - widget.remainingSeconds) ~/ 60}/${widget.selectedDuration} 分钟',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerControls(timerManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPauseResumeButton(timerManager),
        const SizedBox(width: 20),
        _buildCancelButton(timerManager),
      ],
    );
  }

  Widget _buildPauseResumeButton(timerManager) {
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
          const SizedBox(width: 8),
          Text(timerManager.isTimerActive ? '暂停' : '继续'),
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
              content: elapsedMinutes < 1
                  ? const Text('计时不足1分钟，此次计时将不会被记录。确定要取消吗？')
                  : const Text('确定要取消当前计时吗？'),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cancel, size: 24, color: Colors.red),
          const SizedBox(width: 8),
          const Text('取消'),
        ],
      ),
    );
  }
}
