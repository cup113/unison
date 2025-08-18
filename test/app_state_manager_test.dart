import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unison/app_state_manager.dart';
import 'package:unison/timer_manager.dart';
import 'package:unison/todo_manager.dart';
import 'package:unison/todo.dart';

void main() {
  group('AppStateManager', () {
    late AppStateManager appStateManager;
    late TimerManager timerManager;
    late TodoManager todoManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      timerManager = TimerManager();
      await timerManager.loadFromStorage();

      todoManager = TodoManager();
      await todoManager.loadFromStorage();

      appStateManager = AppStateManager(
        timerManager: timerManager,
        todoManager: todoManager,
      );
    });

    tearDown(() {
      appStateManager.dispose();
      timerManager.dispose();
    });

    test('should create AppStateManager with required managers', () {
      expect(appStateManager.timerManager, timerManager);
      expect(appStateManager.todoManager, todoManager);
    });

    test('should have correct preset durations', () {
      final presetDurations = AppStateManager.presetDurations;

      expect(presetDurations,
          [2, 5, 10, 15, 20, 25, 30, 40, 50, 60, 75, 90, 105, 120]);
    });

    group('Focus Records Management', () {
      test('should save focus record with todos', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);

        final todos = [
          Todo(
            id: 'todo-123',
            title: 'Test Todo 1',
            progress: 2,
            total: 10,
          ),
          Todo(
            id: 'todo-456',
            title: 'Test Todo 2',
            progress: 5,
            total: 10,
          ),
        ];

        await appStateManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
          todos: todos,
          progressList: [3, 7],
          focusedTimeList: [15, 5],
        );

        final records = await appStateManager.getFocusRecords();
        expect(records.length, 1);

        final session = records.first;
        expect(session.focusRecord.durationTarget, 25);
        expect(session.focusRecord.durationFocus, 20);
        expect(session.focusTodos.length, 2);

        // Check first todo
        final firstTodo = session.focusTodos[0];
        expect(firstTodo.todoId, 'todo-123');
        expect(firstTodo.duration, 15);
        expect(firstTodo.progressStart, 0);
        expect(firstTodo.progressEnd, 3);

        // Check second todo
        final secondTodo = session.focusTodos[1];
        expect(secondTodo.todoId, 'todo-456');
        expect(secondTodo.duration, 5);
        expect(secondTodo.progressStart, 0);
        expect(secondTodo.progressEnd, 7);
      });

      test('should save focus record without todos', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);

        await appStateManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
        );

        final records = await appStateManager.getFocusRecords();
        expect(records.length, 1);

        final session = records.first;
        expect(session.focusTodos.length, 0);
      });

      test('should handle missing progress and focused time lists', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);

        final todos = [
          Todo(
            id: 'todo-123',
            title: 'Test Todo',
            progress: 5,
            total: 10,
          ),
        ];

        await appStateManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
          todos: todos,
          // progressList and focusedTimeList are null
        );

        final records = await appStateManager.getFocusRecords();
        expect(records.length, 1);

        final session = records.first;
        expect(session.focusTodos.length, 1);

        final focusTodo = session.focusTodos.first;
        expect(focusTodo.todoId, 'todo-123');
        expect(focusTodo.duration, 0); // Default value
        expect(focusTodo.progressStart, 0);
        expect(focusTodo.progressEnd, 5); // From todo's current progress
      });

      test('should get focus records correctly', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);

        // Save multiple records
        await appStateManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
        );

        await appStateManager.saveFocusRecord(
          startTime: startTime.add(const Duration(days: 1)),
          endTime: endTime.add(const Duration(days: 1)),
          plannedDuration: 30,
          actualDuration: 30,
          pauseCount: 0,
          exitCount: 0,
          isCompleted: true,
        );

        final records = await appStateManager.getFocusRecords();
        expect(records.length, 2);
      });

      test('should delete focus record correctly', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);

        await appStateManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
        );

        final recordsBefore = await appStateManager.getFocusRecords();
        expect(recordsBefore.length, 1);

        await appStateManager
            .deleteFocusRecord(recordsBefore.first.focusRecord.id);

        final recordsAfter = await appStateManager.getFocusRecords();
        expect(recordsAfter.length, 0);
      });

      test('should handle empty focus records', () async {
        final records = await appStateManager.getFocusRecords();
        expect(records.length, 0);
      });
    });

    group('Manager Integration', () {
      test('should notify listeners when timer changes', () async {
        var notificationCount = 0;
        appStateManager.addListener(() {
          notificationCount++;
        });

        timerManager.startTimer(25);

        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners when todo changes', () async {
        var notificationCount = 0;
        appStateManager.addListener(() {
          notificationCount++;
        });

        await todoManager.addTodo('Test Todo');

        expect(notificationCount, greaterThan(0));
      });

      test('should provide access to underlying managers', () {
        expect(appStateManager.timerManager, isNotNull);
        expect(appStateManager.todoManager, isNotNull);
      });
    });

    group('Edge Cases', () {
      test('should handle empty todos list gracefully', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);

        await appStateManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
          todos: [], // Empty todos list
          progressList: [],
          focusedTimeList: [],
        );

        final records = await appStateManager.getFocusRecords();
        expect(records.length, 1);

        final session = records.first;
        expect(session.focusTodos.length, 0);
      });

      test('should handle mismatched array lengths gracefully', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);

        final todos = [
          Todo(
            id: 'todo-123',
            title: 'Test Todo 1',
            progress: 2,
            total: 10,
          ),
          Todo(
            id: 'todo-456',
            title: 'Test Todo 2',
            progress: 5,
            total: 10,
          ),
        ];

        await appStateManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
          todos: todos,
          progressList: [3], // Only one progress for two todos
          focusedTimeList: [15, 5, 10], // Three focused times for two todos
        );

        final records = await appStateManager.getFocusRecords();
        expect(records.length, 1);

        final session = records.first;
        expect(session.focusTodos.length, 2);

        // Should use defaults when arrays are too short
        final firstTodo = session.focusTodos[0];
        expect(firstTodo.progressEnd, 3);
        expect(firstTodo.duration, 15);

        final secondTodo = session.focusTodos[1];
        expect(secondTodo.progressEnd, 5); // From todo's current progress
        expect(secondTodo.duration, 5);
      });
    });
  });
}
