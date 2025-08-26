import 'package:flutter/foundation.dart';
import './services/timer_manager.dart';
import './services/todo_manager.dart';
import './models/focus.dart';
import './api/unison_api_service.dart';
import './constants/app_constants.dart';

class AppStateManager with ChangeNotifier {
  static const List<int> presetDurations = AppConstants.presetDurations;

  final TimerManager _timerManager;
  final TodoManager _todoManager;
  final UnisonApiService _apiService;

  AppStateManager({
    required TimerManager timerManager,
    required TodoManager todoManager,
    required UnisonApiService apiService,
  })  : _timerManager = timerManager,
        _todoManager = todoManager,
        _apiService = apiService {
    _timerManager.addListener(_onTimerChanged);
    _todoManager.addListener(_onTodoChanged);
  }

  TimerManager get timerManager => _timerManager;
  TodoManager get todoManager => _todoManager;
  UnisonApiService get apiService => _apiService;

  void _onTimerChanged() {
    notifyListeners();
  }

  void _onTodoChanged() {
    notifyListeners();
  }

// 新增：获取专注记录
  Future<List<FocusSession>> getFocusRecords() async {
    return await _timerManager.getFocusRecords();
  }

  // 删除专注记录
  Future<void> deleteFocusRecord(String id) async {
    await _timerManager.deleteFocusRecord(id);
  }

  @override
  void dispose() {
    _timerManager.removeListener(_onTimerChanged);
    _todoManager.removeListener(_onTodoChanged);
    super.dispose();
  }
}
