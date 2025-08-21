import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unison/todo_manager.dart';

void main() {
  group('TodoManager', () {
    late TodoManager todoManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      todoManager = TodoManager();
      await todoManager.loadFromStorage();
    });

    group('Todo Management', () {
      test('should add todo correctly', () async {
        await todoManager.addTodo('Test Todo',
            category: 'Work', estimatedTime: 30, total: 10);

        expect(todoManager.todos.length, 1);

        final todo = todoManager.todos.first;
        expect(todo.title, 'Test Todo');
        expect(todo.category, 'Work');
        expect(todo.estimatedTime, 30);
        expect(todo.total, 10);
        expect(todo.progress, 0);
        expect(todo.isActive, false);
        expect(todo.isArchived, false);
        expect(todo.focusedTime, 0);
      });

      test('should remove todo correctly', () async {
        await todoManager.addTodo('Test Todo');
        expect(todoManager.todos.length, 1);

        final todoId = todoManager.todos.first.id;
        todoManager.removeTodo(todoId);

        expect(todoManager.todos.length, 0);
      });

      test('should update todo correctly', () async {
        todoManager.addTodo('Original Title',
            category: 'Original', estimatedTime: 10);

        final todoId = todoManager.todos.first.id;
        todoManager.updateTodo(
          todoId,
          'Updated Title',
          category: 'Updated',
          estimatedTime: 20,
          focusedTime: 15,
          total: 15,
        );

        final updatedTodo = todoManager.todos.first;
        expect(updatedTodo.title, 'Updated Title');
        expect(updatedTodo.category, 'Updated');
        expect(updatedTodo.estimatedTime, 20);
        expect(updatedTodo.focusedTime, 15);
        expect(updatedTodo.total, 15);
      });

      test('should set progress correctly', () async {
        await todoManager.addTodo('Test Todo', total: 10);

        final todoId = todoManager.todos.first.id;
        await todoManager.setProgress(todoId, 5);

        final todo = todoManager.todos.first;
        expect(todo.progress, 5);
      });

      test('should add focused time correctly', () async {
        await todoManager.addTodo('Test Todo');

        final todoId = todoManager.todos.first.id;
        await todoManager.addFocusedTime(todoId, 25);

        final todo = todoManager.todos.first;
        expect(todo.focusedTime, 25);

        // Add more time
        await todoManager.addFocusedTime(todoId, 10);
        final updatedTodo = todoManager.todos.first;
        expect(updatedTodo.focusedTime, 35);
      });

      test('should toggle active state correctly', () async {
        await todoManager.addTodo('Test Todo 1');
        await todoManager.addTodo('Test Todo 2');
        final index1 = todoManager.todos.length - 2;
        final index2 = todoManager.todos.length - 1;

        final todo1Id = todoManager.todos[index1].id;
        final todo2Id = todoManager.todos[index2].id;

        // Activate first todo
        await todoManager.toggleActive(todo1Id);
        expect(todoManager.todos[index1].isActive, true);
        expect(todoManager.todos[index2].isActive, false);

        // Activate second todo (should deactivate first)
        await todoManager.toggleActive(todo2Id);
        expect(todoManager.todos[index1].isActive, false);
        expect(todoManager.todos[index2].isActive, true);

        // Deactivate second todo
        await todoManager.toggleActive(todo2Id);
        expect(todoManager.todos[index1].isActive, false);
        expect(todoManager.todos[index2].isActive, false);
      });

      test('should toggle archive state correctly', () async {
        await todoManager.addTodo('Test Todo');

        final todoId = todoManager.todos.first.id;
        expect(todoManager.todos.first.isArchived, false);

        await todoManager.toggleArchive(todoId);
        expect(todoManager.todos.first.isArchived, true);

        await todoManager.toggleArchive(todoId);
        expect(todoManager.todos.first.isArchived, false);
      });
    });

    group('Todo Filtering', () {
      late TodoManager filteringTodoManager;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        filteringTodoManager = TodoManager();
        await filteringTodoManager.loadFromStorage();

        // Create test todos
        await filteringTodoManager.addTodo('Active Todo 1', category: 'Work');
        await filteringTodoManager.addTodo('Active Todo 2',
            category: 'Personal');
        await filteringTodoManager.addTodo('Archived Todo 1', category: 'Work');
        await filteringTodoManager.addTodo('Archived Todo 2',
            category: 'Personal');

        // Store IDs before archiving
        final todo2Id = filteringTodoManager.todos[2].id;
        final todo3Id = filteringTodoManager.todos[3].id;

        // Archive some todos
        await filteringTodoManager.toggleArchive(todo2Id);
        await filteringTodoManager.toggleArchive(todo3Id);
      });

      test('should filter not archived todos correctly', () {
        final notArchived = filteringTodoManager.notArchivedTodos;
        expect(notArchived.length, 2);
        expect(notArchived.every((todo) => !todo.isArchived), true);
      });

      test('should filter archived todos correctly', () {
        final archived = filteringTodoManager.archivedTodos;
        expect(archived.length, 2);
        expect(archived.every((todo) => todo.isArchived), true);
      });

      test('should get active todo correctly', () {
        // No active todo initially
        expect(filteringTodoManager.getActiveTodo(), null);

        // Activate a todo
        final activeTodoId = filteringTodoManager.notArchivedTodos[0].id;
        filteringTodoManager.toggleActive(activeTodoId);

        // Should get active todo
        final activeTodo = filteringTodoManager.getActiveTodo();
        expect(activeTodo, isNotNull);
        expect(activeTodo!.id, activeTodoId);
        expect(activeTodo.isActive, true);
      });

      test('should get active todo with includeCompleted parameter', () async {
        // Create a completed todo and activate it
        await filteringTodoManager.addTodo('Completed Todo', total: 10);
        final completedTodoId = filteringTodoManager.todos.last.id;
        await filteringTodoManager.setProgress(
            completedTodoId, 10); // Complete the todo
        await filteringTodoManager.toggleActive(completedTodoId);

        // Without includeCompleted, should return null
        expect(
            filteringTodoManager.getActiveTodo(includeCompleted: false), null);

        // With includeCompleted, should return the completed active todo
        final activeTodo =
            filteringTodoManager.getActiveTodo(includeCompleted: true);
        expect(activeTodo, isNotNull);
        expect(activeTodo!.id, completedTodoId);
        expect(activeTodo.isCompleted, true);
      });
    });

    group('Storage Persistence', () {
      test('should save and load todos correctly', () async {
        // Add todos
        todoManager.addTodo('Todo 1',
            category: 'Work', estimatedTime: 30, total: 10);
        todoManager.addTodo('Todo 2',
            category: 'Personal', estimatedTime: 15, total: 5);

        // Modify todos
        final todo1Id = todoManager.todos[0].id;
        final todo2Id = todoManager.todos[1].id;

        todoManager.setProgress(todo1Id, 5);
        todoManager.addFocusedTime(todo2Id, 20);
        todoManager.toggleActive(todo1Id);
        todoManager.toggleArchive(todo2Id);

        // Create new manager to test persistence
        final newTodoManager = TodoManager();
        await newTodoManager.loadFromStorage();

        expect(newTodoManager.todos.length, 2);

        // Check first todo
        final loadedTodo1 = newTodoManager.todos[0];
        expect(loadedTodo1.title, 'Todo 1');
        expect(loadedTodo1.category, 'Work');
        expect(loadedTodo1.estimatedTime, 30);
        expect(loadedTodo1.total, 10);
        expect(loadedTodo1.progress, 5);
        expect(loadedTodo1.isActive, true);
        expect(loadedTodo1.isArchived, false);
        expect(loadedTodo1.focusedTime, 0);

        // Check second todo
        final loadedTodo2 = newTodoManager.todos[1];
        expect(loadedTodo2.title, 'Todo 2');
        expect(loadedTodo2.category, 'Personal');
        expect(loadedTodo2.estimatedTime, 15);
        expect(loadedTodo2.total, 5);
        expect(loadedTodo2.progress, 0);
        expect(loadedTodo2.isActive, false);
        expect(loadedTodo2.isArchived, true);
        expect(loadedTodo2.focusedTime, 20);
      });

      test('should handle empty storage correctly', () async {
        SharedPreferences.setMockInitialValues({});

        final newTodoManager = TodoManager();
        await newTodoManager.loadFromStorage();

        expect(newTodoManager.todos.length, 0);
      });
    });

    group('Listener Management', () {
      test('should notify listeners when todo is added', () async {
        var notificationCount = 0;
        todoManager.addListener(() {
          notificationCount++;
        });

        await todoManager.addTodo('Test Todo');

        expect(notificationCount, 1);
      });

      test('should notify listeners when todo is removed', () async {
        await todoManager.addTodo('Test Todo');

        var notificationCount = 0;
        todoManager.addListener(() {
          notificationCount++;
        });

        final todoId = todoManager.todos.first.id;
        await todoManager.removeTodo(todoId);

        expect(notificationCount, 1);
      });

      test('should notify listeners when todo is updated', () async {
        await todoManager.addTodo('Test Todo');

        var notificationCount = 0;
        todoManager.addListener(() {
          notificationCount++;
        });

        final todoId = todoManager.todos.first.id;
        await todoManager.setProgress(todoId, 5);

        expect(notificationCount, 1);
      });

      test('should remove listener correctly', () async {
        var notificationCount = 0;
        listener() {
          notificationCount++;
        }

        todoManager.addListener(listener);
        await todoManager.addTodo('Test Todo');
        expect(notificationCount, 1);

        todoManager.removeListener(listener);
        todoManager.addTodo('Another Todo');
        expect(notificationCount, 1); // Should not increase
      });
    });

    group('Edge Cases', () {
      test('should handle removing non-existent todo', () async {
        expect(
            () => todoManager.removeTodo('non-existent-id'), returnsNormally);
        expect(todoManager.todos.length, 0);
      });

      test('should handle updating non-existent todo', () async {
        expect(() => todoManager.updateTodo('non-existent-id', 'New Title'),
            returnsNormally);
        expect(todoManager.todos.length, 0);
      });

      test('should handle setting progress for non-existent todo', () async {
        expect(() => todoManager.setProgress('non-existent-id', 5),
            returnsNormally);
        expect(todoManager.todos.length, 0);
      });

      test('should handle adding focused time to non-existent todo', () async {
        expect(() => todoManager.addFocusedTime('non-existent-id', 10),
            returnsNormally);
        expect(todoManager.todos.length, 0);
      });

      test('should handle toggling active state for non-existent todo',
          () async {
        expect(
            () => todoManager.toggleActive('non-existent-id'), returnsNormally);
        expect(todoManager.todos.length, 0);
      });

      test('should handle toggling archive state for non-existent todo',
          () async {
        expect(() => todoManager.toggleArchive('non-existent-id'),
            returnsNormally);
        expect(todoManager.todos.length, 0);
      });

      test('should handle adding todo with default values', () async {
        todoManager.addTodo('Minimal Todo');

        final todo = todoManager.todos.first;
        expect(todo.title, 'Minimal Todo');
        expect(todo.category, '');
        expect(todo.estimatedTime, 0);
        expect(todo.total, 10);
        expect(todo.progress, 0);
        expect(todo.isActive, false);
        expect(todo.isArchived, false);
        expect(todo.focusedTime, 0);
      });
    });
  });
}
