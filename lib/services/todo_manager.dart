import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:unison/utils/list_extensions.dart';
import '../models/todo.dart';
import '../utils/app_errors.dart';
import 'todo_manager_interface.dart';
import 'storage_service.dart';

class TodoManager with ChangeNotifier implements TodoManagerInterface {
  final List<Todo> _todos = [];

  @override
  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);

  // 使用 ChangeNotifier 的内置监听器功能，无需手动实现

  @override
  Future<void> loadFromStorage() async {
    try {
      _todos.clear();
      _todos.addAll(await StorageService.loadTodos());
      notifyListeners();
    } catch (e) {
      throw StorageError('Failed to load todos from storage',
          underlyingError: e);
    }
  }

  @override
  Future<void> saveToStorage() async {
    try {
      await StorageService.saveTodos(_todos);
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
    notifyListeners();
  }

  @override
  Future<void> removeTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    await saveToStorage();
    notifyListeners();
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
      notifyListeners();
    }
  }

// 添加设置进度的方法
  @override
  Future<void> setProgress(String id, int progress) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(progress: progress);
      await saveToStorage();
      notifyListeners();
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
      notifyListeners();
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
    notifyListeners();
  }

  @override
  Future<void> toggleArchive(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;
    final newValue = !_todos[index].isArchived;
    _todos[index] = _todos[index].copyWith(isArchived: newValue);
    await saveToStorage();
    notifyListeners();
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