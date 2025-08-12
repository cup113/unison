import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerManager with ChangeNotifier {
  static const List<int> presetDurations = [25, 40, 60, 90]; // in minutes

  int? _selectedDuration;
  int? _remainingSeconds;
  Timer? _timer;
  int _exitCount = 0;
  bool _isPaused = false;

  int? get selectedDuration => _selectedDuration;
  int? get remainingSeconds => _remainingSeconds;
  int get exitCount => _exitCount;
  bool get isPaused => _isPaused;
  bool get isTimerActive => _timer?.isActive ?? false;

  void startTimer(int minutes) {
    _selectedDuration = minutes;
    _remainingSeconds = minutes * 60;
    _isPaused = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds! > 0) {
        _remainingSeconds = _remainingSeconds! - 1;
        notifyListeners();
      } else {
        _timer?.cancel();
        notifyListeners();
      }
    });

    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isPaused = true;
    notifyListeners();
  }

  void resumeTimer() {
    if (_remainingSeconds != null && _remainingSeconds! > 0) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds! > 0) {
          _remainingSeconds = _remainingSeconds! - 1;
        } else {
          _timer?.cancel();
        }
        _isPaused = false;
        notifyListeners();
      });
    }
  }

  void cancelTimer() {
    _timer?.cancel();
    _selectedDuration = null;
    _remainingSeconds = null;
    _isPaused = false;
    notifyListeners();
  }

  void incrementExitCount() {
    _exitCount++;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
