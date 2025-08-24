import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unison/utils/list_extensions.dart';
import '../models/todo.dart';
import '../constants/app_constants.dart';
import '../utils/app_errors.dart';
import 'todo_manager_interface.dart';

class TodoManager with ChangeNotifier implements TodoManagerInterface {
  final List<Todo> _todos = [];
  final List<VoidCallback> _listeners = [];

  static const String _todoListKey = AppConstants.todoListKey;

  @override
  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    final listeners = List<VoidCallback>.from(_listeners);
    for (final listener in listeners) {
      listener();
    }
  }

  @override
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 加载待办事项列表
      final todoListString = prefs.getString(_todoListKey);
      if (todoListString != null) {
        try {
          final List<dynamic> todoListJson = json.decode(todoListString);
          _todos.clear();
          for (final todoJson in todoListJson) {
            _todos.add(
              Todo(
                id: todoJson['id'],
                title: todoJson['title'],
                progress: todoJson['progress'],
                isActive: todoJson['isActive'],
                isArchived: todoJson['isArchived'] ?? false,
                category: todoJson['category'],
                estimatedTime: todoJson['estimatedTime'],
                focusedTime: todoJson['focusedTime'] ?? 0,
                total: todoJson['total'] ?? 10,
              ),
            );
          }
        } catch (e) {
          // If JSON parsing fails, clear the todos and continue
          _todos.clear();
          throw StorageError('Failed to parse todo list from storage',
              underlyingError: e);
        }
      }

      _notifyListeners();
    } catch (e) {
      throw StorageError('Failed to load todos from storage',
          underlyingError: e);
    }
  }

  @override
  Future<void> saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存待办事项列表
      final List<Map<String, dynamic>> todoListJson = _todos
          .map(
            (todo) => {
              'id': todo.id,
              'title': todo.title,
              'progress': todo.progress,
              'isActive': todo.isActive,
              'isArchived': todo.isArchived,
              'category': todo.category,
              'estimatedTime': todo.estimatedTime,
              'focusedTime': todo.focusedTime,
              'total': todo.total,
            },
          )
          .toList();
      await prefs.setString(_todoListKey, json.encode(todoListJson));
    } catch (e) {
      throw StorageError('Failed to save todos to storage', underlyingError: e);
    }
  }

  @override
  Future<void> addTodo(String title,
      {String category = '', int estimatedTime = 0, int total = 10}) async {
    final todo = Todo(
      id: nanoid(),
      title: title,
      category: category,
      estimatedTime: estimatedTime,
      total: total,
    );
    _todos.add(todo);
    await saveToStorage();
    _notifyListeners();
  }

  @override
  Future<void> removeTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    await saveToStorage();
    _notifyListeners();
  }

  @override
  Future<void> updateTodo(
    String id,
    String title, {
    String? category,
    int? estimatedTime,
    int? focusedTime,
    int? total,
  }) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        title: title,
        category: category,
        estimatedTime: estimatedTime,
        focusedTime: focusedTime,
        total: total,
      );
      await saveToStorage();
      _notifyListeners();
    }
  }

// 添加设置进度的方法
  @override
  Future<void> setProgress(String id, int progress) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(progress: progress);
      await saveToStorage();
      _notifyListeners();
    }
  }

// 添加增加专注时间的方法
  @override
  Future<void> addFocusedTime(String id, int minutes) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        focusedTime: _todos[index].focusedTime + minutes,
      );
      await saveToStorage();
      _notifyListeners();
    }
  }

  @override
  Future<void> toggleActive(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;
    if (_todos[index].isActive) {
      // 如果当前任务已处于活动状态，则将其取消
      _todos[index] = _todos[index].copyWith(isActive: false);
    } else {
      // 先取消其他所有活动项
      for (int i = 0; i < _todos.length; i++) {
        if (_todos[i].isActive) {
          _todos[i] = _todos[i].copyWith(isActive: false);
        }
      }
      _todos[index] = _todos[index].copyWith(isActive: true);
    }

    await saveToStorage();
    _notifyListeners();
  }

  @override
  Future<void> toggleArchive(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;
    final newValue = !_todos[index].isArchived;
    _todos[index] = _todos[index].copyWith(isArchived: newValue);
    await saveToStorage();
    _notifyListeners();
  }

  @override
  List<Todo> get notArchivedTodos =>
      _todos.where((todo) => !todo.isArchived).toList();
  @override
  List<Todo> get archivedTodos =>
      _todos.where((todo) => todo.isArchived).toList();

  @override
  Todo? getActiveTodo({bool includeCompleted = false}) {
    if (includeCompleted) {
      return _todos.firstWhereOrNull((todo) => todo.isActive);
    } else {
      return _todos.firstWhereOrNull(
        (todo) => todo.isActive && !todo.isCompleted,
      );
    }
  }
}

typedef VoidCallback = void Function();
