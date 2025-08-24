import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/todo.dart';

typedef VoidCallback = void Function();

abstract class TodoManagerInterface with ChangeNotifier {
  UnmodifiableListView<Todo> get todos;
  List<Todo> get notArchivedTodos;
  List<Todo> get archivedTodos;
  Todo? getActiveTodo({bool includeCompleted = false});

  @override
  void addListener(VoidCallback listener);
  @override
  void removeListener(VoidCallback listener);

  Future<void> loadFromStorage();
  Future<void> saveToStorage();

  Future<void> addTodo(
    String title, {
    String category,
    int estimatedTime,
    int total,
  });

  Future<void> removeTodo(String id);
  Future<void> updateTodo(
    String id,
    String title, {
    String? category,
    int? estimatedTime,
    int? focusedTime,
    int? total,
  });

  Future<void> setProgress(String id, int progress);
  Future<void> addFocusedTime(String id, int minutes);
  Future<void> toggleActive(String id);
  Future<void> toggleArchive(String id);
}
