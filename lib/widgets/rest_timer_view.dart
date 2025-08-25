import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unison/services/timer_manager_interface.dart';
import '../providers.dart';

class RestTimerView extends ConsumerStatefulWidget {
  const RestTimerView({super.key});

  @override
  ConsumerState<RestTimerView> createState() => _RestTimerViewState();
}

class _RestTimerViewState extends ConsumerState<RestTimerView> {
  @override
  Widget build(BuildContext context) {
    final timerManager = ref.watch(timerManagerProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimerDisplay(timerManager.remainingSeconds ?? 0),
            const SizedBox(height: 30),
            _buildTimerControls(timerManager),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(int remainingSeconds) {
    final totalSeconds = remainingSeconds.abs();
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    final isNegative = remainingSeconds < 0;

    return Column(
      children: [
        Text(
          '${isNegative ? '-' : ''}${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.orange : Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '放松一下 ☕',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerControls(TimerManagerInterface timerManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPauseResumeButton(timerManager),
        const SizedBox(width: 20),
        _buildCompleteButton(),
      ],
    );
  }

  Widget _buildPauseResumeButton(TimerManagerInterface timerManager) {
    return ElevatedButton(
      onPressed: () {
        if (timerManager.isTimerActive) {
          timerManager.pauseTimer();
        } else {
          timerManager.resumeTimer();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget _buildCompleteButton() {
    return ElevatedButton(
      onPressed: () {
        final timerManager = ref.read(timerManagerProvider);
        timerManager.cancelRestTimer();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 24),
          SizedBox(width: 8),
          Text('完成休息'),
        ],
      ),
    );
  }
}
