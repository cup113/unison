import 'package:flutter/foundation.dart';
import 'timer_manager.dart';
import 'todo.dart';
import 'todo_manager.dart';

class AppStateManager with ChangeNotifier {
  static const List<int> presetDurations = [
    2,
    5,
    10,
    15,
    20,
    25,
    30,
    40,
    50,
    60,
    75,
    90,
    105,
    120,
  ]; // in minutes

  final TimerManager _timerManager;
  final TodoManager _todoManager;

  AppStateManager({
    required TimerManager timerManager,
    required TodoManager todoManager,
  })  : _timerManager = timerManager,
        _todoManager = todoManager {
    _timerManager.addListener(_onTimerChanged);
    _todoManager.addListener(_onTodoChanged);
  }

  TimerManager get timerManager => _timerManager;
  TodoManager get todoManager => _todoManager;

  void _onTimerChanged() {
    notifyListeners();
  }

  void _onTodoChanged() {
    notifyListeners();
  }

  // 新增：保存专注记录，支持多个todo
  Future<void> saveFocusRecord({
    required DateTime startTime,
    required DateTime endTime,
    required int plannedDuration,
    required int actualDuration,
    required int pauseCount,
    required int exitCount,
    required bool isCompleted, // 新增：显式标记是否完成
    List<Todo>? todos, // 支持关联多个todo
    List<int>? progressList, // 对应的进度列表
    List<int>? focusedTimeList, // 对应的专注时间列表
  }) async {
    List<Map<String, dynamic>>? todoData;

    if (todos != null && progressList != null && focusedTimeList != null) {
      todoData = [];
      for (int i = 0; i < todos.length; i++) {
        todoData.add({
          'todoId': todos[i].id,
          'todoTitle': todos[i].title,
          'todoProgress':
              i < progressList.length ? progressList[i] : todos[i].progress,
          'todoFocusedTime':
              i < focusedTimeList.length ? focusedTimeList[i] : 0,
        });
      }
    }

    await _timerManager.saveFocusRecord(
      startTime: startTime,
      endTime: endTime,
      plannedDuration: plannedDuration,
      actualDuration: actualDuration,
      pauseCount: pauseCount,
      exitCount: exitCount,
      isCompleted: isCompleted, // 传递完成状态
      todoData: todoData,
    );
  }

  // 新增：获取专注记录
  Future<List<Map<String, dynamic>>> getFocusRecords() async {
    return await _timerManager.getFocusRecords();
  }

  @override
  void dispose() {
    _timerManager.removeListener(_onTimerChanged);
    _todoManager.removeListener(_onTodoChanged);
    super.dispose();
  }
}
