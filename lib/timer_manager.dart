import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerManager with ChangeNotifier {
  static const List<int> presetDurations = [25, 40, 60, 90]; // in minutes

  int? _selectedDuration;
  int? _remainingSeconds;
  Timer? _timer;
  int _exitCount = 0;
  bool _isPaused = false;

  static const String _timerStateKey = 'timer_state';

  int? get selectedDuration => _selectedDuration;
  int? get remainingSeconds => _remainingSeconds;
  int get exitCount => _exitCount;
  bool get isPaused => _isPaused;
  bool get isTimerActive => _timer?.isActive ?? false;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载计时器状态
    final timerStateString = prefs.getString(_timerStateKey);
    if (timerStateString != null) {
      final Map<String, dynamic> timerState = json.decode(timerStateString);

      _selectedDuration = timerState['selectedDuration'];
      _remainingSeconds = timerState['remainingSeconds'];
      _exitCount = timerState['exitCount'] ?? 0;
      _isPaused = timerState['isPaused'] ?? false;

      // 如果有待定的计时器，则恢复它
      if (_remainingSeconds != null && _remainingSeconds! > 0 && !_isPaused) {
        resumeTimer();
      }
    }
  }

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存计时器状态
    if (_selectedDuration != null) {
      final Map<String, dynamic> timerState = {
        'selectedDuration': _selectedDuration,
        'remainingSeconds': _remainingSeconds,
        'exitCount': _exitCount,
        'isPaused': _isPaused,
      };
      prefs.setString(_timerStateKey, json.encode(timerState));
    } else {
      prefs.remove(_timerStateKey);
    }
  }

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

    saveToStorage();
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isPaused = true;
    saveToStorage();
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
        saveToStorage();
        notifyListeners();
      });
    }
  }

  void cancelTimer() {
    _timer?.cancel();
    _selectedDuration = null;
    _remainingSeconds = null;
    _isPaused = false;
    saveToStorage();
    notifyListeners();
  }

  void incrementExitCount() {
    _exitCount++;
    saveToStorage();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
