import 'package:flutter/foundation.dart';
import 'timer_manager.dart';
import 'todo_manager.dart';

class AppStateManager with ChangeNotifier {
  static const List<int> presetDurations = [
    5,
    15,
    25,
    40,
    60,
    90
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

  @override
  void dispose() {
    _timerManager.removeListener(_onTimerChanged);
    _todoManager.removeListener(_onTodoChanged);
    super.dispose();
  }
}
