import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/focus.dart';
import '../models/timer_state.dart';
import '../constants/app_constants.dart';
import 'timer_manager_interface.dart';

class TimerManager with ChangeNotifier implements TimerManagerInterface {
  static const String _timerStateKey = AppConstants.timerStateKey;
  static const String _focusRecordsKey = AppConstants.focusRecordsKey;

  TimerState _state = TimerState();
  Timer? _timer;
  DateTime? _lastTickTime;

  @override
  int? get selectedDuration => _state.selectedDuration;
  @override
  int? get remainingSeconds => _state.remainingSeconds;
  @override
  int get exitCount => _state.exitCount;
  @override
  int get pauseCount => _state.pauseCount;
  @override
  bool get isPaused => _state.isPaused;
  @override
  bool get isTimerActive => _timer?.isActive ?? false;
  @override
  bool get isRest => _state.isRest ?? false;
  @override
  DateTime? get startTime => _state.startTime;
  @override
  DateTime? get lastExitTime => _state.lastExitTime;

  @override
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final timerStateString = prefs.getString(_timerStateKey);

    if (timerStateString != null) {
      try {
        _state = TimerState.fromJson(json.decode(timerStateString));

        // 如果有待定的计时器，则恢复它
        final shouldResume = _state.remainingSeconds != null &&
            _state.remainingSeconds! > 0 &&
            !_state.isPaused;
        if (shouldResume) {
          resumeTimer();
        }
      } catch (e) {
        _state = TimerState(isRest: false);
      }
    }
  }

  @override
  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    if (_state.selectedDuration != null) {
      prefs.setString(_timerStateKey, json.encode(_state.toJson()));
    } else {
      prefs.remove(_timerStateKey);
    }
  }

  @override
  Future<void> saveFocusRecord({
    required DateTime startTime,
    required DateTime endTime,
    required int plannedDuration,
    required int actualDuration,
    required int pauseCount,
    required int exitCount,
    required bool isCompleted,
    required String focusId,
    List<FocusTodo>? todoData,
  }) async {
    if (!isRest) {
      _state = TimerState(isRest: true);
    }
    final prefs = await SharedPreferences.getInstance();
    final recordsString = prefs.getString(_focusRecordsKey);
    final List<dynamic> records =
        recordsString != null ? json.decode(recordsString) : [];

    // 计算中断时长（基于暂停次数和退出次数的估算）
    final int interruptedDuration =
        (pauseCount * 2) + (exitCount * 3); // TODO 简单估算

    // 创建新的FocusRecord
    final focusRecord = FocusRecord(
      id: focusId,
      start: startTime,
      end: endTime,
      durationTarget: plannedDuration,
      durationFocus: actualDuration,
      durationInterrupted: interruptedDuration,
      isCompleted: isCompleted, // 使用显式的完成状态
    );

    // 如果有todo数据，创建FocusTodo记录
    final List<FocusTodo> focusTodos = [];
    if (todoData != null) {
      for (int i = 0; i < todoData.length; i++) {
        focusTodos.add(todoData[i]);
      }
    }

    // 创建FocusSession
    final focusSession = FocusSession(
      focusRecord: focusRecord,
      focusTodos: focusTodos,
    );

    records.add(focusSession.toJson());
    prefs.setString(_focusRecordsKey, json.encode(records));
  }

  @override
  Future<List<FocusSession>> getFocusRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsString = prefs.getString(_focusRecordsKey);

    if (recordsString != null) {
      try {
        final List<dynamic> records = json.decode(recordsString);
        return records.map((record) => FocusSession.fromJson(record)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> deleteFocusRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsString = prefs.getString(_focusRecordsKey);

    if (recordsString != null) {
      try {
        final List<dynamic> records = json.decode(recordsString);
        records.removeWhere((record) => record['focusRecord']['id'] == id);
        prefs.setString(_focusRecordsKey, json.encode(records));
      } catch (e) {
        // 如果解析失败，不做任何操作
      }
    }
  }

  @override
  void startTimer(int minutes) {
    _timer?.cancel();

    _state = TimerState(
      selectedDuration: minutes,
      remainingSeconds: minutes * 60,
      isPaused: false,
      isRest: isRest,
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
  @override
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

      if (_lastTickTime != null) {
        final difference = now.difference(_lastTickTime!).inSeconds;
        if (difference > 2) {
          final newRemaining = _state.remainingSeconds! - (difference - 1);
          _state = _state.copyWith(remainingSeconds: newRemaining);
        }
      }

      _lastTickTime = now;

      // Update the correct state
      final newRemaining = _state.remainingSeconds! - 1;
      _state = _state.copyWith(remainingSeconds: newRemaining);

      notifyListeners();
      saveToStorage();
    });
  }

  @override
  void pauseTimer() {
    _timer?.cancel();
    _state = _state.copyWith(
      isPaused: true,
      pauseCount: _state.pauseCount + 1,
    );
    saveToStorage();
    notifyListeners();
  }

  @override
  void cancelTimer(bool finished) {
    _timer?.cancel();

    bool isRest = true;

    if (_state.startTime != null && _state.selectedDuration != null) {
      final endTime = DateTime.now();
      final actualDurationMinutes = (_state.selectedDuration! * 60 -
              (_state.remainingSeconds ?? _state.selectedDuration! * 60)) ~/
          60;

      if (!finished && actualDurationMinutes > 0) {
        // TODO: Currently, when finished, there is another call, and it should be unified later.
        saveFocusRecord(
          focusId: nanoid(),
          startTime: _state.startTime!,
          endTime: endTime,
          plannedDuration: _state.selectedDuration!,
          actualDuration: actualDurationMinutes,
          pauseCount: _state.pauseCount,
          exitCount: _state.exitCount,
          isCompleted: finished, // 根据用户操作显式设置完成状态
        );
        isRest = actualDurationMinutes > 0;
      }
    }

    // 重置状态
    _state = TimerState(isRest: isRest);
    saveToStorage();
    notifyListeners();
  }

  // 增加时间
  @override
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

  @override
  void skipRest() {
    _state = TimerState(isRest: false);
    notifyListeners();
    saveToStorage();
  }

  @override
  void cancelRestTimer() {
    _timer?.cancel();
    _state = TimerState(isRest: false);
    notifyListeners();
    saveToStorage();
  }

  // 处理应用退出
  @override
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
