import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerState {
  final int? selectedDuration; // 选定的持续时间（分钟）
  final int? remainingSeconds; // 剩余秒数
  final bool isPaused; // 是否暂停
  final int exitCount; // 退出次数
  final int pauseCount; // 暂停次数
  final DateTime? startTime; // 开始时间
  final DateTime? lastExitTime; // 上次退出时间

  TimerState({
    this.selectedDuration,
    this.remainingSeconds,
    this.isPaused = false,
    this.exitCount = 0,
    this.pauseCount = 0,
    this.startTime,
    this.lastExitTime,
  });

  TimerState copyWith({
    int? selectedDuration,
    int? remainingSeconds,
    bool? isPaused,
    int? exitCount,
    int? pauseCount,
    DateTime? startTime,
    DateTime? lastExitTime,
  }) {
    return TimerState(
      selectedDuration: selectedDuration ?? this.selectedDuration,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isPaused: isPaused ?? this.isPaused,
      exitCount: exitCount ?? this.exitCount,
      pauseCount: pauseCount ?? this.pauseCount,
      startTime: startTime ?? this.startTime,
      lastExitTime: lastExitTime ?? this.lastExitTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedDuration': selectedDuration,
      'remainingSeconds': remainingSeconds,
      'isPaused': isPaused,
      'exitCount': exitCount,
      'pauseCount': pauseCount,
      'startTime': startTime?.millisecondsSinceEpoch,
      'lastExitTime': lastExitTime?.millisecondsSinceEpoch,
    };
  }

  factory TimerState.fromMap(Map<String, dynamic> map) {
    return TimerState(
      selectedDuration: map['selectedDuration'],
      remainingSeconds: map['remainingSeconds'],
      isPaused: map['isPaused'] ?? false,
      exitCount: map['exitCount'] ?? 0,
      pauseCount: map['pauseCount'] ?? 0,
      startTime: map['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startTime'])
          : null,
      lastExitTime: map['lastExitTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastExitTime'])
          : null,
    );
  }
}

class TimerManager with ChangeNotifier {
  static const String _timerStateKey = 'timer_state_v2';
  static const String _focusRecordsKey = 'focus_records_v2';

  TimerState _state = TimerState();
  Timer? _timer;
  DateTime? _lastTickTime;

  // Getters
  int? get selectedDuration => _state.selectedDuration;
  int? get remainingSeconds => _state.remainingSeconds;
  int get exitCount => _state.exitCount;
  int get pauseCount => _state.pauseCount;
  bool get isPaused => _state.isPaused;
  bool get isTimerActive => _timer?.isActive ?? false;
  DateTime? get startTime => _state.startTime;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final timerStateString = prefs.getString(_timerStateKey);

    if (timerStateString != null) {
      try {
        final Map<String, dynamic> timerStateMap =
            json.decode(timerStateString);
        _state = TimerState.fromMap(timerStateMap);

        // 如果有待定的计时器，则恢复它
        if (_state.remainingSeconds != null &&
            _state.remainingSeconds! > 0 &&
            !_state.isPaused) {
          resumeTimer();
        }
      } catch (e) {
        // 如果解析失败，重置状态
        _state = TimerState();
      }
    }
  }

  // 保存状态到存储
  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    if (_state.selectedDuration != null) {
      prefs.setString(_timerStateKey, json.encode(_state.toMap()));
    } else {
      prefs.remove(_timerStateKey);
    }
  }

  // 保存专注记录
  Future<void> saveFocusRecord({
    required DateTime startTime,
    required DateTime endTime,
    required int plannedDuration,
    required int actualDuration,
    required int pauseCount,
    required int exitCount,
    required bool isCompleted,
    List<Map<String, dynamic>>? todoData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsString = prefs.getString(_focusRecordsKey);
    final List<dynamic> records =
        recordsString != null ? json.decode(recordsString) : [];

    final newRecord = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'plannedDuration': plannedDuration,
      'actualDuration': actualDuration,
      'pauseCount': pauseCount,
      'exitCount': exitCount,
      'isCompleted': isCompleted,
      if (todoData != null) 'todoData': todoData,
    };

    records.add(newRecord);
    prefs.setString(_focusRecordsKey, json.encode(records));
  }

// 获取专注记录
  Future<List<Map<String, dynamic>>> getFocusRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsString = prefs.getString(_focusRecordsKey);

    if (recordsString != null) {
      try {
        return List<Map<String, dynamic>>.from(json.decode(recordsString));
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  // 删除专注记录
  Future<void> deleteFocusRecord(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsString = prefs.getString(_focusRecordsKey);

    if (recordsString != null) {
      try {
        final List<dynamic> records = json.decode(recordsString);
        records.removeWhere((record) => record['id'] == id);
        prefs.setString(_focusRecordsKey, json.encode(records));
      } catch (e) {
        // 如果解析失败，不做任何操作
      }
    }
  }

  // 开始计时器
  void startTimer(int minutes) {
    _timer?.cancel();

    _state = TimerState(
      selectedDuration: minutes,
      remainingSeconds: minutes * 60,
      isPaused: false,
      exitCount: 0,
      pauseCount: 0,
      startTime: DateTime.now(),
    );

    _lastTickTime = _state.startTime;
    _startTimerPeriodic();
    saveToStorage();
    notifyListeners();
  }

  // 恢复计时器
  void resumeTimer() {
    if (_state.remainingSeconds != null && _state.remainingSeconds != 0) {
      _timer?.cancel();
      _lastTickTime = DateTime.now();
      _startTimerPeriodic();
      _state = _state.copyWith(isPaused: false);
      notifyListeners();
    }
  }

  // 启动周期性计时器
  void _startTimerPeriodic() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      // 处理应用暂停后的时间补偿
      if (_lastTickTime != null) {
        final difference = now.difference(_lastTickTime!).inSeconds;
        if (difference > 2) {
          // 补偿暂停期间的时间
          _state = _state.copyWith(
            remainingSeconds: _state.remainingSeconds! - (difference - 1),
          );
        }
      }

      _lastTickTime = now;
      _state = _state.copyWith(
        remainingSeconds: _state.remainingSeconds! - 1,
      );

      notifyListeners();
      saveToStorage();
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _state = _state.copyWith(
      isPaused: true,
      pauseCount: _state.pauseCount + 1,
    );
    saveToStorage();
    notifyListeners();
  }

  void cancelTimer(bool finished) {
    _timer?.cancel();

    // 如果计时器已经开始且有实际专注时间，则保存记录
    if (_state.startTime != null && _state.selectedDuration != null) {
      final endTime = DateTime.now();
      final actualDurationMinutes = (_state.selectedDuration! * 60 -
              (_state.remainingSeconds ?? _state.selectedDuration! * 60)) ~/
          60;

      if (!finished && actualDurationMinutes > 0) {
        saveFocusRecord(
          startTime: _state.startTime!,
          endTime: endTime,
          plannedDuration: _state.selectedDuration!,
          actualDuration: actualDurationMinutes,
          pauseCount: _state.pauseCount,
          exitCount: _state.exitCount,
          isCompleted: false,
        );
      }
    }

    // 重置状态
    _state = TimerState();
    saveToStorage();
    notifyListeners();
  }

  // 增加时间
  void addTime(int minutes) {
    if (_state.remainingSeconds != null) {
      _state = _state.copyWith(
        remainingSeconds: _state.remainingSeconds! + (minutes * 60),
        selectedDuration: _state.selectedDuration! + minutes,
      );
      notifyListeners();
      saveToStorage();
    }
  }

  // 处理应用退出
  void handleAppExit() {
    final now = DateTime.now();
    int newExitCount = _state.exitCount;

    if (_state.lastExitTime != null) {
      final difference = now.difference(_state.lastExitTime!).inSeconds;
      if (difference >= 3) {
        newExitCount++;
      }
    } else {
      newExitCount++;
    }

    _state = _state.copyWith(
      exitCount: newExitCount,
      lastExitTime: now,
    );

    saveToStorage();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
