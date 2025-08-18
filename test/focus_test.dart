import 'package:flutter_test/flutter_test.dart';
import 'package:unison/focus.dart';

void main() {
  group('FocusRecord', () {
    test('should create FocusRecord with correct properties', () {
      final startTime = DateTime(2024, 1, 1, 10, 0);
      final endTime = DateTime(2024, 1, 1, 10, 30);

      final focusRecord = FocusRecord(
        id: 'test-id',
        start: startTime,
        end: endTime,
        durationTarget: 30,
        durationFocus: 25,
        durationInterrupted: 5,
        userId: 'user-123',
      );

      expect(focusRecord.id, 'test-id');
      expect(focusRecord.start, startTime);
      expect(focusRecord.end, endTime);
      expect(focusRecord.durationTarget, 30);
      expect(focusRecord.durationFocus, 25);
      expect(focusRecord.durationInterrupted, 5);
      expect(focusRecord.userId, 'user-123');
    });

    test('should calculate duration getters correctly', () {
      final focusRecord = FocusRecord(
        id: 'test-id',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 25,
        durationInterrupted: 5,
      );

      expect(focusRecord.durationFocusSeconds, 25 * 60);
      expect(focusRecord.durationInterruptedSeconds, 5 * 60);
      expect(focusRecord.durationTargetSeconds, 30 * 60);
    });

    test('should calculate completion rate correctly', () {
      final focusRecord1 = FocusRecord(
        id: 'test-id-1',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 25,
        durationInterrupted: 5,
      );

      final focusRecord2 = FocusRecord(
        id: 'test-id-2',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 30,
        durationInterrupted: 0,
      );

      expect(focusRecord1.completionRate, 25 / 30 * 100);
      expect(focusRecord2.completionRate, 100.0);
    });

    test('should determine completion status correctly', () {
      final focusRecord1 = FocusRecord(
        id: 'test-id-1',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 25,
        durationInterrupted: 5,
      );

      final focusRecord2 = FocusRecord(
        id: 'test-id-2',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 30,
        durationInterrupted: 0,
      );

      expect(focusRecord1.isCompleted, false);
      expect(focusRecord2.isCompleted, true);
    });

    test('should serialize and deserialize correctly', () {
      final original = FocusRecord(
        id: 'test-id',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 25,
        durationInterrupted: 5,
        userId: 'user-123',
      );

      final map = original.toMap();
      final deserialized = FocusRecord.fromMap(map);

      expect(deserialized.id, original.id);
      expect(deserialized.start, original.start);
      expect(deserialized.end, original.end);
      expect(deserialized.durationTarget, original.durationTarget);
      expect(deserialized.durationFocus, original.durationFocus);
      expect(deserialized.durationInterrupted, original.durationInterrupted);
      expect(deserialized.userId, original.userId);
    });

    test('should copy with new values correctly', () {
      final original = FocusRecord(
        id: 'test-id',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 25,
        durationInterrupted: 5,
      );

      final copied = original.copyWith(
        durationFocus: 30,
        durationInterrupted: 0,
      );

      expect(copied.id, original.id);
      expect(copied.start, original.start);
      expect(copied.end, original.end);
      expect(copied.durationTarget, original.durationTarget);
      expect(copied.durationFocus, 30);
      expect(copied.durationInterrupted, 0);
    });
  });

  group('FocusTodo', () {
    test('should create FocusTodo with correct properties', () {
      final focusTodo = FocusTodo(
        id: 'test-todo-id',
        todoId: 'todo-123',
        focusId: 'focus-123',
        duration: 25,
        progressStart: 2,
        progressEnd: 5,
      );

      expect(focusTodo.id, 'test-todo-id');
      expect(focusTodo.todoId, 'todo-123');
      expect(focusTodo.focusId, 'focus-123');
      expect(focusTodo.duration, 25);
      expect(focusTodo.progressStart, 2);
      expect(focusTodo.progressEnd, 5);
    });

    test('should calculate progress improvement correctly', () {
      final focusTodo = FocusTodo(
        id: 'test-todo-id',
        todoId: 'todo-123',
        focusId: 'focus-123',
        duration: 25,
        progressStart: 2,
        progressEnd: 5,
      );

      expect(focusTodo.progressImprovement, 3);
    });

    test('should serialize and deserialize correctly', () {
      final original = FocusTodo(
        id: 'test-todo-id',
        todoId: 'todo-123',
        focusId: 'focus-123',
        duration: 25,
        progressStart: 2,
        progressEnd: 5,
      );

      final map = original.toMap();
      final deserialized = FocusTodo.fromMap(map);

      expect(deserialized.id, original.id);
      expect(deserialized.todoId, original.todoId);
      expect(deserialized.focusId, original.focusId);
      expect(deserialized.duration, original.duration);
      expect(deserialized.progressStart, original.progressStart);
      expect(deserialized.progressEnd, original.progressEnd);
    });
  });

  group('AppUsage', () {
    test('should create AppUsage with correct properties', () {
      final startTime = DateTime(2024, 1, 1, 10, 0);
      final endTime = DateTime(2024, 1, 1, 10, 15);

      final appUsage = AppUsage(
        id: 'test-usage-id',
        appName: 'Test App',
        start: startTime,
        end: endTime,
        duration: 15,
        userId: 'user-123',
      );

      expect(appUsage.id, 'test-usage-id');
      expect(appUsage.appName, 'Test App');
      expect(appUsage.start, startTime);
      expect(appUsage.end, endTime);
      expect(appUsage.duration, 15);
      expect(appUsage.userId, 'user-123');
    });

    test('should serialize and deserialize correctly', () {
      final original = AppUsage(
        id: 'test-usage-id',
        appName: 'Test App',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 15),
        duration: 15,
        userId: 'user-123',
      );

      final map = original.toMap();
      final deserialized = AppUsage.fromMap(map);

      expect(deserialized.id, original.id);
      expect(deserialized.appName, original.appName);
      expect(deserialized.start, original.start);
      expect(deserialized.end, original.end);
      expect(deserialized.duration, original.duration);
      expect(deserialized.userId, original.userId);
    });
  });

  group('FocusSession', () {
    test('should create FocusSession with correct properties', () {
      final focusRecord = FocusRecord(
        id: 'focus-id',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 25,
        durationInterrupted: 5,
      );

      final focusTodos = [
        FocusTodo(
          id: 'todo-1',
          todoId: 'todo-123',
          focusId: 'focus-id',
          duration: 25,
          progressStart: 2,
          progressEnd: 5,
        ),
      ];

      final focusSession = FocusSession(
        focusRecord: focusRecord,
        focusTodos: focusTodos,
      );

      expect(focusSession.focusRecord, focusRecord);
      expect(focusSession.focusTodos, focusTodos);
      expect(focusSession.appUsages, null);
    });

    test('should calculate session metrics correctly', () {
      final focusRecord = FocusRecord(
        id: 'focus-id',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 25,
        durationInterrupted: 5,
      );

      final focusTodos = [
        FocusTodo(
          id: 'todo-1',
          todoId: 'todo-123',
          focusId: 'focus-id',
          duration: 25,
          progressStart: 2,
          progressEnd: 5,
        ),
        FocusTodo(
          id: 'todo-2',
          todoId: 'todo-456',
          focusId: 'focus-id',
          duration: 15,
          progressStart: 1,
          progressEnd: 3,
        ),
      ];

      final focusSession = FocusSession(
        focusRecord: focusRecord,
        focusTodos: focusTodos,
      );

      expect(focusSession.totalDuration, 25);
      expect(focusSession.todoCount, 2);
      expect(focusSession.averageProgressImprovement, (3 + 2) / 2);
    });

    test('should handle empty focus todos list', () {
      final focusRecord = FocusRecord(
        id: 'focus-id',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 25,
        durationInterrupted: 5,
      );

      final focusSession = FocusSession(
        focusRecord: focusRecord,
        focusTodos: [],
      );

      expect(focusSession.totalDuration, 25);
      expect(focusSession.todoCount, 0);
      expect(focusSession.averageProgressImprovement, 0);
    });

    test('should serialize and deserialize correctly', () {
      final focusRecord = FocusRecord(
        id: 'focus-id',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 30),
        durationTarget: 30,
        durationFocus: 25,
        durationInterrupted: 5,
      );

      final focusTodos = [
        FocusTodo(
          id: 'todo-1',
          todoId: 'todo-123',
          focusId: 'focus-id',
          duration: 25,
          progressStart: 2,
          progressEnd: 5,
        ),
      ];

      final appUsages = [
        AppUsage(
          id: 'usage-1',
          appName: 'Test App',
          start: DateTime(2024, 1, 1, 10, 0),
          end: DateTime(2024, 1, 1, 10, 15),
          duration: 15,
        ),
      ];

      final original = FocusSession(
        focusRecord: focusRecord,
        focusTodos: focusTodos,
        appUsages: appUsages,
      );

      final map = original.toMap();
      final deserialized = FocusSession.fromMap(map);

      expect(deserialized.focusRecord.id, original.focusRecord.id);
      expect(deserialized.focusTodos.length, original.focusTodos.length);
      expect(deserialized.appUsages?.length, original.appUsages?.length);
    });
  });
}
