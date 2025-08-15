import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerManager with ChangeNotifier {
  int? _selectedDuration;
  int? _remainingSeconds;
  Timer? _timer;
  int _exitCount = 0;
  bool _isPaused = false;
  DateTime? _lastExitTime; // 记录上次退出时间
  int _pauseCount = 0; // 暂停次数
  DateTime? _startTime; // 开始时间
  DateTime? _lastTickTime; // 上次计时时间
  static const String _timerStateKey = 'timer_state_v2';
  static const String _focusRecordsKey = 'focus_records_v2';

  int? get selectedDuration => _selectedDuration;
  int? get remainingSeconds => _remainingSeconds;
  int get exitCount => _exitCount;
  int get pauseCount => _pauseCount;
  bool get isPaused => _isPaused;
  bool get isTimerActive => _timer?.isActive ?? false;
  DateTime? get startTime => _startTime;

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
      _pauseCount = timerState['pauseCount'] ?? 0;
      _startTime = timerState['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(timerState['startTime'])
          : null;
      _lastExitTime = timerState['lastExitTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(timerState['lastExitTime'])
          : null;
      _lastTickTime = timerState['lastTickTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(timerState['lastTickTime'])
          : null;

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
        'pauseCount': _pauseCount,
        'startTime': _startTime?.millisecondsSinceEpoch,
        'lastExitTime': _lastExitTime?.millisecondsSinceEpoch,
        'lastTickTime': _lastTickTime?.millisecondsSinceEpoch,
      };
      prefs.setString(_timerStateKey, json.encode(timerState));
    } else {
      prefs.remove(_timerStateKey);
    }
  }

  // 修改：保存专注记录，支持多个todo关联
  Future<void> saveFocusRecord({
    required DateTime startTime,
    required DateTime endTime,
    required int plannedDuration, // 分钟
    required int actualDuration, // 分钟
    required int pauseCount,
    required int exitCount,
    List<Map<String, dynamic>>? todoData, // 修改为支持多个todo
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 获取现有的专注记录
    final recordsString = prefs.getString(_focusRecordsKey);
    final List<dynamic> records =
        recordsString != null ? json.decode(recordsString) : [];

    // 添加新记录
    final newRecord = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'plannedDuration': plannedDuration,
      'actualDuration': actualDuration,
      'pauseCount': pauseCount,
      'exitCount': exitCount,
      if (todoData != null) 'todoData': todoData,
    };

    records.add(newRecord);

    // 保存更新后的记录列表
    prefs.setString(_focusRecordsKey, json.encode(records));
  }

  void startTimer(int minutes) {
    _selectedDuration = minutes;
    _remainingSeconds = minutes * 60;
    _isPaused = false;
    _pauseCount = 0; // 重置暂停次数
    _exitCount = 0; // 重置退出次数
    _startTime = DateTime.now(); // 记录开始时间
    _lastTickTime = _startTime; // 初始化上次调用时间为开始时间

    _timer?.cancel();
    _startTimerPeriodic();
    saveToStorage();
    notifyListeners();
  }

  void resumeTimer() {
    if (_remainingSeconds != null && _remainingSeconds != 0) {
      _timer?.cancel();
      _startTimerPeriodic();
      notifyListeners();
    }
  }

  // 提取公共的计时器逻辑到私有方法
  void _startTimerPeriodic() {
    _lastTickTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      // 检查距离上次调用的时间间隔
      if (_lastTickTime != null) {
        final difference = now.difference(_lastTickTime!).inSeconds;
        // 如果间隔超过2秒，说明有暂停，需要补偿
        if (difference > 2) {
          _remainingSeconds = _remainingSeconds! - (difference - 1);
        }
      }
      _lastTickTime = now;

      // 修改：允许remainingSeconds为负数，继续倒计时
      _remainingSeconds = _remainingSeconds! - 1;
      notifyListeners();

      saveToStorage();
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isPaused = true;
    _pauseCount++; // 增加暂停次数
    saveToStorage();
    notifyListeners();
  }

  void cancelTimer(bool finished) {
    _timer?.cancel();

    // 如果计时器被取消且已经开始，则保存记录
    if (_startTime != null && _selectedDuration != null) {
      final endTime = DateTime.now();
      final actualDurationMinutes = (_selectedDuration! * 60 -
              (_remainingSeconds ?? _selectedDuration! * 60)) ~/
          60;

      // 只有当实际专注时间大于0时才保存记录
      if (!finished && actualDurationMinutes > 0) {
        saveFocusRecord(
          startTime: _startTime!,
          endTime: endTime,
          plannedDuration: _selectedDuration!,
          actualDuration: actualDurationMinutes,
          pauseCount: _pauseCount,
          exitCount: _exitCount,
        );
      }
    }

    _selectedDuration = null;
    _remainingSeconds = null;
    _isPaused = false;
    _startTime = null;
    saveToStorage();
    notifyListeners();
  }

  // 新增：增加时间功能
  void addTime(int minutes) {
    if (_remainingSeconds != null) {
      _remainingSeconds = _remainingSeconds! + (minutes * 60);
      _selectedDuration = _selectedDuration! + minutes;
      notifyListeners();
      saveToStorage();
    }
  }

  // 新增：获取专注记录
  Future<List<Map<String, dynamic>>> getFocusRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsString = prefs.getString(_focusRecordsKey);
    if (recordsString != null) {
      try {
        return List<Map<String, dynamic>>.from(json.decode(recordsString));
      } catch (e) {
        // 如果解析失败，返回空列表
        return [];
      }
    }
    return [];
  }

  // 修改：处理退出计数逻辑
  void handleAppExit() {
    final now = DateTime.now();
    if (_lastExitTime != null) {
      final difference = now.difference(_lastExitTime!).inSeconds;
      // 如果距离上次退出小于3秒，则不增加退出次数
      if (difference >= 3) {
        _exitCount++;
      }
    } else {
      // 第一次退出
      _exitCount++;
    }
    _lastExitTime = now;
    saveToStorage();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
