import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unison/timer_manager.dart';

void main() {
  group('TimerManager', () {
    late TimerManager timerManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      timerManager = TimerManager();
      await timerManager.loadFromStorage();
    });

    tearDown(() {
      timerManager.dispose();
    });

    group('TimerState', () {
      test('should create TimerState with default values', () {
        final state = TimerState();

        expect(state.selectedDuration, null);
        expect(state.remainingSeconds, null);
        expect(state.isPaused, false);
        expect(state.exitCount, 0);
        expect(state.pauseCount, 0);
        expect(state.startTime, null);
        expect(state.lastExitTime, null);
      });

      test('should create TimerState with custom values', () {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final state = TimerState(
          selectedDuration: 25,
          remainingSeconds: 1500,
          isPaused: true,
          exitCount: 2,
          pauseCount: 3,
          startTime: startTime,
        );

        expect(state.selectedDuration, 25);
        expect(state.remainingSeconds, 1500);
        expect(state.isPaused, true);
        expect(state.exitCount, 2);
        expect(state.pauseCount, 3);
        expect(state.startTime, startTime);
      });

      test('should copy TimerState with new values', () {
        final original = TimerState(
          selectedDuration: 25,
          remainingSeconds: 1500,
          isPaused: true,
          exitCount: 2,
          pauseCount: 3,
        );

        final copied = original.copyWith(
          selectedDuration: 30,
          isPaused: false,
        );

        expect(copied.selectedDuration, 30);
        expect(copied.remainingSeconds, 1500);
        expect(copied.isPaused, false);
        expect(copied.exitCount, 2);
        expect(copied.pauseCount, 3);
      });

      test('should serialize and deserialize TimerState correctly', () {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final lastExitTime = DateTime(2024, 1, 1, 10, 30);

        final original = TimerState(
          selectedDuration: 25,
          remainingSeconds: 1500,
          isPaused: true,
          exitCount: 2,
          pauseCount: 3,
          startTime: startTime,
          lastExitTime: lastExitTime,
        );

        final map = original.toMap();
        final deserialized = TimerState.fromMap(map);

        expect(deserialized.selectedDuration, original.selectedDuration);
        expect(deserialized.remainingSeconds, original.remainingSeconds);
        expect(deserialized.isPaused, original.isPaused);
        expect(deserialized.exitCount, original.exitCount);
        expect(deserialized.pauseCount, original.pauseCount);
        expect(deserialized.startTime, original.startTime);
        expect(deserialized.lastExitTime, original.lastExitTime);
      });
    });

    group('Timer Management', () {
      test('should start timer correctly', () async {
        timerManager.startTimer(25);

        expect(timerManager.selectedDuration, 25);
        expect(timerManager.remainingSeconds, 1500); // 25 * 60
        expect(timerManager.isPaused, false);
        expect(timerManager.exitCount, 0);
        expect(timerManager.pauseCount, 0);
        expect(timerManager.startTime, isNotNull);
        expect(timerManager.isTimerActive, true);
      });

      test('should pause timer correctly', () async {
        timerManager.startTimer(25);
        timerManager.pauseTimer();

        expect(timerManager.isPaused, true);
        expect(timerManager.pauseCount, 1);
        expect(timerManager.isTimerActive, false);
      });

      test('should resume timer correctly', () async {
        timerManager.startTimer(25);
        timerManager.pauseTimer();
        timerManager.resumeTimer();

        expect(timerManager.isPaused, false);
        expect(timerManager.isTimerActive, true);
      });

      test('should add time correctly', () async {
        timerManager.startTimer(25);
        final initialRemaining = timerManager.remainingSeconds;

        timerManager.addTime(5);

        expect(
            timerManager.remainingSeconds, initialRemaining! + 300); // 5 * 60
        expect(timerManager.selectedDuration, 30); // 25 + 5
      });

      test('should handle app exit correctly', () async {
        timerManager.startTimer(25);

        timerManager.handleAppExit();
        expect(timerManager.exitCount, 1);
        expect(timerManager.lastExitTime, isNotNull);

        // Quick second exit should not increment count
        timerManager.handleAppExit();
        expect(timerManager.exitCount, 1);
      });

      test('should cancel timer correctly when finished', () async {
        timerManager.startTimer(25);

        timerManager.cancelTimer(true);

        expect(timerManager.isTimerActive, false);
        expect(timerManager.selectedDuration, null);
        expect(timerManager.remainingSeconds, null);
      });

      test('should cancel timer and save record when not finished', () async {
        timerManager.startTimer(25);

        // Simulate some time passing
        await Future.delayed(const Duration(milliseconds: 100));

        timerManager.cancelTimer(false);

        expect(timerManager.isTimerActive, false);
        expect(timerManager.selectedDuration, null);
        expect(timerManager.remainingSeconds, null);
      });
    });

    group('Focus Records Management', () {
      test('should save focus record correctly', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);
        final todoData = [
          {
            'todoId': 'todo-123',
            'todoTitle': 'Test Todo',
            'todoProgress': 5,
            'todoFocusedTime': 20,
          },
        ];

        await timerManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
          todoData: todoData,
        );

        final records = await timerManager.getFocusRecords();
        expect(records.length, 1);

        final session = records.first;
        expect(session.focusRecord.durationTarget, 25);
        expect(session.focusRecord.durationFocus, 20);
        expect(session.focusRecord.durationInterrupted, 9); // (2 * 2) + (1 * 5)
        expect(session.focusTodos.length, 1);
        expect(session.focusTodos.first.todoId, 'todo-123');
      });

      test('should save focus record without todo data', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);

        await timerManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
        );

        final records = await timerManager.getFocusRecords();
        expect(records.length, 1);

        final session = records.first;
        expect(session.focusTodos.length, 0);
      });

      test('should get focus records correctly', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);

        // Save multiple records
        await timerManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
        );

        await timerManager.saveFocusRecord(
          startTime: startTime.add(const Duration(days: 1)),
          endTime: endTime.add(const Duration(days: 1)),
          plannedDuration: 30,
          actualDuration: 30,
          pauseCount: 0,
          exitCount: 0,
          isCompleted: true,
        );

        final records = await timerManager.getFocusRecords();
        expect(records.length, 2);
      });

      test('should delete focus record correctly', () async {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 10, 25);

        await timerManager.saveFocusRecord(
          startTime: startTime,
          endTime: endTime,
          plannedDuration: 25,
          actualDuration: 20,
          pauseCount: 2,
          exitCount: 1,
          isCompleted: false,
        );

        final recordsBefore = await timerManager.getFocusRecords();
        expect(recordsBefore.length, 1);

        await timerManager
            .deleteFocusRecord(recordsBefore.first.focusRecord.id);

        final recordsAfter = await timerManager.getFocusRecords();
        expect(recordsAfter.length, 0);
      });

      test('should handle empty focus records', () async {
        final records = await timerManager.getFocusRecords();
        expect(records.length, 0);
      });
    });

    group('Storage Persistence', () {
      test('should save and load timer state correctly', () async {
        timerManager.startTimer(25);
        timerManager.pauseTimer();

        // Create new instance to test persistence
        final newTimerManager = TimerManager();
        await newTimerManager.loadFromStorage();

        expect(newTimerManager.selectedDuration, 25);
        expect(newTimerManager.remainingSeconds, 1500);
        expect(newTimerManager.isPaused, true);
        expect(newTimerManager.pauseCount, 1);

        newTimerManager.dispose();
      });
    });
  });
}
