import 'package:flutter/foundation.dart';
import './services/timer_manager.dart';
import './models/todo.dart';
import './services/todo_manager.dart';
import './models/focus.dart';
import './services/auth_service.dart';
import './constants/app_constants.dart';

class AppStateManager with ChangeNotifier {
  static const List<int> presetDurations = AppConstants.presetDurations;

  final TimerManager _timerManager;
  final TodoManager _todoManager;
  final AuthService _authService;

  bool _isLoggedIn = false;
  String _username = '';
  String _email = '';
  String _id = '';
  bool _isInitialized = false;

  AppStateManager({
    required TimerManager timerManager,
    required TodoManager todoManager,
    required AuthService authService,
  })  : _timerManager = timerManager,
        _todoManager = todoManager,
        _authService = authService {
    _timerManager.addListener(_onTimerChanged);
    _todoManager.addListener(_onTodoChanged);
  }

  TimerManager get timerManager => _timerManager;
  TodoManager get todoManager => _todoManager;

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;
  bool get isInitialized => _isInitialized;
  String get id => _id;

  void _onTimerChanged() {
    notifyListeners();
  }

  void _onTodoChanged() {
    notifyListeners();
  }

  Future<void> initializeAuth() async {
    try {
      final userData = await _authService.initializeAuth();
      if (userData != null) {
        _isLoggedIn = true;
        _username = userData['name'] ?? '';
        _email = userData['email'] ?? '';
        _id = userData['id'] ?? '';
      } else {
        _isLoggedIn = false;
        _username = '';
        _email = '';
        _id = '';
      }
    } catch (e) {
      _isLoggedIn = false;
      _username = '';
      _email = '';
      _id = '';
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
    await updateAuthState();
  }

  Future<void> register(String name, String email, String password) async {
    await _authService.register(name, email, password);
    await updateAuthState();
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _username = '';
    _email = '';
    _id = '';
    notifyListeners();
  }

  Future<void> updateAuthState() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      _isLoggedIn = true;
      _username = userData['name'] ?? '';
      _email = userData['email'] ?? '';
      _id = userData['id'] ?? '';
    } else {
      _isLoggedIn = false;
      _username = '';
      _email = '';
      _id = '';
    }
    notifyListeners();
  }

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

    if (todos != null) {
      todoData = [];
      for (int i = 0; i < todos.length; i++) {
        todoData.add({
          'todoId': todos[i].id,
          'todoTitle': todos[i].title,
          'todoCategory': todos[i].category,
          'todoProgressStart': todos[i].progress, // 保存开始进度
          'todoProgress': progressList != null && i < progressList.length
              ? progressList[i]
              : todos[i].progress,
          'todoFocusedTime':
              focusedTimeList != null && i < focusedTimeList.length
                  ? focusedTimeList[i]
                  : 0,
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
