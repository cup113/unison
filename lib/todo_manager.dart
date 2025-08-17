import 'dart:collection';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo.dart';

class TodoManager {
  final List<Todo> _todos = [];
  final List<VoidCallback> _listeners = [];

  static const String _todoListKey = 'todo_list_v2';

  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载待办事项列表
    final todoListString = prefs.getString(_todoListKey);
    if (todoListString != null) {
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
          ),
        );
      }
    }

    _notifyListeners();
  }

  Future<void> saveToStorage() async {
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
          },
        )
        .toList();
    prefs.setString(_todoListKey, json.encode(todoListJson));
  }

  void addTodo(String title, {String category = '', int estimatedTime = 0}) {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      estimatedTime: estimatedTime,
    );
    _todos.add(todo);
    saveToStorage();
    _notifyListeners();
  }

  void removeTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    saveToStorage();
    _notifyListeners();
  }

  void updateTodo(
    String id,
    String title, {
    String? category,
    int? estimatedTime,
    int? focusedTime,
  }) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        title: title,
        category: category,
        estimatedTime: estimatedTime,
        focusedTime: focusedTime,
      );
      saveToStorage();
      _notifyListeners();
    }
  }

  // 添加设置进度的方法
  void setProgress(String id, int progress) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(progress: progress);
      saveToStorage();
      _notifyListeners();
    }
  }

  // 添加增加专注时间的方法
  void addFocusedTime(String id, int minutes) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        focusedTime: _todos[index].focusedTime + minutes,
      );
      saveToStorage();
      _notifyListeners();
    }
  }

  void toggleActive(String id) {
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
      _todos[index] = _todos[index].copyWith(isActive: !_todos[index].isActive);
    }

    saveToStorage();
    _notifyListeners();
  }

  void toggleArchive(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;
    _todos[index] =
        _todos[index].copyWith(isArchived: !_todos[index].isArchived);
    _notifyListeners();
  }

  List<Todo> get notArchivedTodos =>
      _todos.where((todo) => !todo.isArchived).toList();
  List<Todo> get archivedTodos =>
      _todos.where((todo) => todo.isArchived).toList();

  // 修改 getActiveTodo 方法，添加 includeCompleted 参数
  Todo? getActiveTodo({bool includeCompleted = false}) {
    if (includeCompleted) {
      // 如果 includeCompleted 为 true，则返回所有活动任务，包括已完成的
      return _todos.firstWhereOrNull((todo) => todo.isActive);
    } else {
      // 原来的逻辑，只返回未完成的活动任务
      return _todos.firstWhereOrNull(
        (todo) => todo.isActive && !todo.isCompleted,
      );
    }
  }
}

typedef VoidCallback = void Function();

extension FirstWhereOrNullExtension<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
