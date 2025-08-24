import 'package:hive_flutter/hive_flutter.dart';
import 'package:unison/models/todo.dart';
import 'package:unison/models/focus.dart';
import 'package:unison/utils/app_errors.dart';

class HiveService {
  static const String todoBoxName = 'todos';
  static const String focusBoxName = 'focus_sessions';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TodoAdapter());
    Hive.registerAdapter(FocusRecordAdapter());
    Hive.registerAdapter(FocusTodoAdapter());
    Hive.registerAdapter(AppUsageAdapter());
    Hive.registerAdapter(FocusSessionAdapter());

    // Open boxes
    await Hive.openBox<Todo>(todoBoxName);
    await Hive.openBox<FocusSession>(focusBoxName);
  }

  // Todo operations
  static Future<List<Todo>> getAllTodos() async {
    try {
      final box = Hive.box<Todo>(todoBoxName);
      return box.values.toList();
    } catch (e) {
      throw StorageError('Failed to load todos from Hive', underlyingError: e);
    }
  }

  static Future<void> saveTodo(Todo todo) async {
    try {
      final box = Hive.box<Todo>(todoBoxName);
      await box.put(todo.id, todo);
    } catch (e) {
      throw StorageError('Failed to save todo to Hive', underlyingError: e);
    }
  }

  static Future<void> deleteTodo(String id) async {
    try {
      final box = Hive.box<Todo>(todoBoxName);
      await box.delete(id);
    } catch (e) {
      throw StorageError('Failed to delete todo from Hive', underlyingError: e);
    }
  }

  static Future<void> saveAllTodos(List<Todo> todos) async {
    try {
      final box = Hive.box<Todo>(todoBoxName);
      await box.clear();
      final Map<String, Todo> todoMap = {for (var todo in todos) todo.id: todo};
      await box.putAll(todoMap);
    } catch (e) {
      throw StorageError('Failed to save todos to Hive', underlyingError: e);
    }
  }

  // Focus session operations
  static Future<List<FocusSession>> getAllFocusSessions() async {
    try {
      final box = Hive.box<FocusSession>(focusBoxName);
      return box.values.toList();
    } catch (e) {
      throw StorageError('Failed to load focus sessions from Hive',
          underlyingError: e);
    }
  }

  static Future<void> saveFocusSession(FocusSession session) async {
    try {
      final box = Hive.box<FocusSession>(focusBoxName);
      await box.put(session.focusRecord.id, session);
    } catch (e) {
      throw StorageError('Failed to save focus session to Hive',
          underlyingError: e);
    }
  }

  static Future<void> deleteFocusSession(String id) async {
    try {
      final box = Hive.box<FocusSession>(focusBoxName);
      await box.delete(id);
    } catch (e) {
      throw StorageError('Failed to delete focus session from Hive',
          underlyingError: e);
    }
  }

  static Future<void> clearAllData() async {
    try {
      final todoBox = Hive.box<Todo>(todoBoxName);
      final focusBox = Hive.box<FocusSession>(focusBoxName);
      await todoBox.clear();
      await focusBox.clear();
    } catch (e) {
      throw StorageError('Failed to clear Hive data', underlyingError: e);
    }
  }
}
