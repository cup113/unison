import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/focus.dart';
import '../models/todo.dart';
import '../models/timer_state.dart';
import '../constants/app_constants.dart';
import '../utils/app_errors.dart';
import 'logging_service.dart';

class StorageService {
  static const String _timerStateKey = AppConstants.timerStateKey;
  static const String _focusRecordsKey = AppConstants.focusRecordsKey;
  static const String _todoListKey = AppConstants.todoListKey;
  static const String _userInfoKey = AppConstants.userInfoKey;

  /// 获取 SharedPreferences 实例
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // ========== 计时器状态存储 ==========

  /// 保存计时器状态
  static Future<void> saveTimerState(TimerState state) async {
    try {
      final prefs = await _getPrefs();
      if (state.selectedDuration != null) {
        await prefs.setString(_timerStateKey, json.encode(state.toJson()));
        LoggingService().debug('Timer state saved', context: {
          'selectedDuration': state.selectedDuration,
          'remainingSeconds': state.remainingSeconds,
          'isPaused': state.isPaused,
        });
      } else {
        await prefs.remove(_timerStateKey);
        LoggingService().debug('Timer state cleared');
      }
    } catch (e, stackTrace) {
      LoggingService().error('Failed to save timer state', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 加载计时器状态
  static Future<TimerState?> loadTimerState() async {
    try {
      final prefs = await _getPrefs();
      final timerStateString = prefs.getString(_timerStateKey);

      if (timerStateString != null) {
        try {
          final state = TimerState.fromJson(json.decode(timerStateString));
          LoggingService().debug('Timer state loaded', context: {
            'selectedDuration': state.selectedDuration,
            'remainingSeconds': state.remainingSeconds,
            'isPaused': state.isPaused,
          });
          return state;
        } catch (e, stackTrace) {
          // 如果解析失败，清除无效数据
          LoggingService().warning('Invalid timer state data, clearing corrupted data', 
            stackTrace: stackTrace);
          await prefs.remove(_timerStateKey);
          return TimerState(isRest: false);
        }
      }
      return null;
    } catch (e, stackTrace) {
      LoggingService().error('Failed to load timer state', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 清除计时器状态
  static Future<void> clearTimerState() async {
    final prefs = await _getPrefs();
    await prefs.remove(_timerStateKey);
  }

  // ========== 专注记录存储 ==========

  /// 保存专注记录
  static Future<void> saveFocusRecords(List<FocusSession> sessions) async {
    final prefs = await _getPrefs();
    final recordsJson = sessions.map((session) => session.toJson()).toList();
    await prefs.setString(_focusRecordsKey, json.encode(recordsJson));
  }

  /// 加载专注记录
  static Future<List<FocusSession>> loadFocusRecords() async {
    final prefs = await _getPrefs();
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

  /// 删除专注记录
  static Future<void> deleteFocusRecord(String id) async {
    final prefs = await _getPrefs();
    final recordsString = prefs.getString(_focusRecordsKey);

    if (recordsString != null) {
      try {
        final List<dynamic> records = json.decode(recordsString);
        records.removeWhere((record) => record['focusRecord']['id'] == id);
        await prefs.setString(_focusRecordsKey, json.encode(records));
      } catch (e) {
        // 如果解析失败，不做任何操作
      }
    }
  }

  /// 清除所有专注记录
  static Future<void> clearFocusRecords() async {
    final prefs = await _getPrefs();
    await prefs.remove(_focusRecordsKey);
  }

  // ========== 待办事项存储 ==========

  /// 保存待办事项列表
  static Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await _getPrefs();
    await prefs.setString(
        _todoListKey, json.encode(todos.map((todo) => todo.toJson()).toList()));
  }

  /// 加载待办事项列表
  static Future<List<Todo>> loadTodos() async {
    final prefs = await _getPrefs();
    final todoListString = prefs.getString(_todoListKey);

    if (todoListString != null) {
      try {
        final List<dynamic> todoListJson = json.decode(todoListString);
        return todoListJson
            .map((todoJson) => Todo(
                  id: todoJson['id'],
                  title: todoJson['title'],
                  progress: todoJson['progress'],
                  isActive: todoJson['isActive'],
                  isArchived: todoJson['isArchived'] ?? false,
                  category: todoJson['category'],
                  estimatedTime: todoJson['estimatedTime'],
                  focusedTime: todoJson['focusedTime'] ?? 0,
                  total: todoJson['total'] ?? 10,
                ))
            .toList();
      } catch (e) {
        throw StorageError('Failed to parse todo list from storage',
            underlyingError: e);
      }
    }
    return [];
  }

  /// 清除待办事项
  static Future<void> clearTodos() async {
    final prefs = await _getPrefs();
    await prefs.remove(_todoListKey);
  }

  // ========== 用户信息存储 ==========

  /// 保存用户信息
  static Future<void> saveUserInfo(Map<String, dynamic> userData) async {
    final prefs = await _getPrefs();
    await prefs.setString(_userInfoKey, json.encode(userData));
  }

  /// 加载用户信息
  static Future<Map<String, dynamic>?> loadUserInfo() async {
    final prefs = await _getPrefs();
    final user = prefs.getString(_userInfoKey);

    if (user != null && user.isNotEmpty) {
      try {
        return json.decode(user);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// 清除用户信息
  static Future<void> clearUserInfo() async {
    final prefs = await _getPrefs();
    await prefs.remove(_userInfoKey);
  }

  // ========== 通用方法 ==========

  /// 清除所有应用数据
  static Future<void> clearAllData() async {
    final prefs = await _getPrefs();
    await prefs.remove(_timerStateKey);
    await prefs.remove(_focusRecordsKey);
    await prefs.remove(_todoListKey);
    await prefs.remove(_userInfoKey);
  }
}
