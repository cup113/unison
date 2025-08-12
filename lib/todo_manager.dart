import 'dart:collection';
import 'todo.dart';

class TodoManager {
  final List<Todo> _todos = [];
  final List<VoidCallback> _listeners = [];

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

  void addTodo(String title) {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    _todos.add(todo);
    _notifyListeners();
  }

  void removeTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    _notifyListeners();
  }

  void updateTodo(String id, String title) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(title: title);
      _notifyListeners();
    }
  }

  void toggleCompleted(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      _notifyListeners();
    }
  }

  void toggleActive(String id) {
    // 先取消其他所有活动项
    for (int i = 0; i < _todos.length; i++) {
      if (_todos[i].isActive) {
        _todos[i] = _todos[i].copyWith(isActive: false);
      }
    }

    // 激活当前项
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(isActive: !_todos[index].isActive);
      _notifyListeners();
    }
  }

  Todo? getActiveTodo() {
    return _todos.firstWhereOrNull(
      (todo) => todo.isActive && !todo.isCompleted,
    );
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
