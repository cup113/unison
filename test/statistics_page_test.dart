import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unison/statistics_page.dart';
import 'package:unison/app_state_manager.dart';
import 'package:unison/focus.dart';

class MockAppStateManager extends Mock implements AppStateManager {}

void main() {
  group('StatisticsPage', () {
    late MockAppStateManager mockAppStateManager;

    setUp(() {
      mockAppStateManager = MockAppStateManager();
    });

    testWidgets('should display loading indicator initially',
        (WidgetTester tester) async {
      // Mock loading state
      when(() => mockAppStateManager.getFocusRecords())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(appStateManager: mockAppStateManager),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no records',
        (WidgetTester tester) async {
      // Mock empty records
      when(() => mockAppStateManager.getFocusRecords())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(appStateManager: mockAppStateManager),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      expect(find.text('暂无统计数据\n完成专注任务后将在此显示统计数据'), findsOneWidget);
    });

    testWidgets('should display summary card with records',
        (WidgetTester tester) async {
      // Create test focus sessions
      final focusRecord1 = FocusRecord(
        id: 'focus-1',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 25),
        durationTarget: 25,
        durationFocus: 25,
        durationInterrupted: 0,
        isCompleted: true,
      );

      final focusRecord2 = FocusRecord(
        id: 'focus-2',
        start: DateTime(2024, 1, 1, 11, 0),
        end: DateTime(2024, 1, 1, 11, 20),
        durationTarget: 30,
        durationFocus: 20,
        durationInterrupted: 10,
        isCompleted: true,
      );

      final sessions = [
        FocusSession(focusRecord: focusRecord1, focusTodos: []),
        FocusSession(focusRecord: focusRecord2, focusTodos: []),
      ];

      when(() => mockAppStateManager.getFocusRecords())
          .thenAnswer((_) async => sessions);

      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(appStateManager: mockAppStateManager),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Check summary card
      expect(find.text('总览'), findsOneWidget);
      expect(find.text('专注次数'), findsOneWidget);
      expect(find.text('2 次'), findsOneWidget);
      expect(find.text('专注时长'), findsOneWidget);
      expect(find.text('45 分钟'), findsOneWidget); // 25 + 20
      expect(find.text('计划时长'), findsOneWidget);
      expect(find.text('55 分钟'), findsOneWidget); // 25 + 30
      expect(find.text('完成率'), findsOneWidget);
      expect(find.text('50.0%'), findsOneWidget); // 1/2 completed
    });

    testWidgets('should display 7 days change card',
        (WidgetTester tester) async {
      // Create test focus sessions for different days
      final sessions = [
        FocusSession(
          focusRecord: FocusRecord(
            id: 'focus-1',
            start: DateTime(2024, 1, 6, 10, 0), // Yesterday
            end: DateTime(2024, 1, 6, 10, 30),
            durationTarget: 30,
            durationFocus: 30,
            durationInterrupted: 0,
            isCompleted: true,
          ),
          focusTodos: [],
        ),
        FocusSession(
          focusRecord: FocusRecord(
            id: 'focus-2',
            start: DateTime(2024, 1, 7, 10, 0), // Today
            end: DateTime(2024, 1, 7, 10, 25),
            durationTarget: 25,
            durationFocus: 25,
            durationInterrupted: 0,
            isCompleted: true,
          ),
          focusTodos: [],
        ),
      ];

      when(() => mockAppStateManager.getFocusRecords())
          .thenAnswer((_) async => sessions);

      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(appStateManager: mockAppStateManager),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Check 7 days change card
      expect(find.text('近7天变化'), findsOneWidget);
      expect(find.text('平均每日专注'), findsOneWidget);
      expect(find.text('最专注的一天'), findsOneWidget);
    });

    testWidgets('should display focus history records',
        (WidgetTester tester) async {
      final focusRecord = FocusRecord(
        id: 'focus-1',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 25),
        durationTarget: 25,
        durationFocus: 25,
        durationInterrupted: 0,
        isCompleted: true,
      );

      final focusTodo = FocusTodo(
        id: 'todo-1',
        todoId: 'todo-123',
        focusId: 'focus-1',
        duration: 25,
        progressStart: 0,
        progressEnd: 5,
      );

      final session = FocusSession(
        focusRecord: focusRecord,
        focusTodos: [focusTodo],
      );

      when(() => mockAppStateManager.getFocusRecords())
          .thenAnswer((_) async => [session]);

      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(appStateManager: mockAppStateManager),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // TODO check title
      expect(find.text('计划'), findsOneWidget);
      expect(find.text('25 分钟'), findsOneWidget);
      expect(find.text('实际'), findsOneWidget);
      expect(find.text('25 分钟'), findsAtLeastNWidgets(2));
      expect(find.text('中断'), findsOneWidget);
      expect(find.text('0 分钟'), findsOneWidget);
      expect(find.text('完成率'), findsOneWidget);
      expect(find.text('100.0%'), findsOneWidget);
      expect(find.text('关联任务:'), findsOneWidget);
    });

    testWidgets('should display delete button and handle deletion',
        (WidgetTester tester) async {
      final focusRecord = FocusRecord(
        id: 'focus-1',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 25),
        durationTarget: 25,
        durationFocus: 25,
        durationInterrupted: 0,
        isCompleted: true,
      );

      final session = FocusSession(
        focusRecord: focusRecord,
        focusTodos: [],
      );

      when(() => mockAppStateManager.getFocusRecords())
          .thenAnswer((_) async => [session]);

      // Mock delete method
      when(() => mockAppStateManager.deleteFocusRecord('focus-1'))
          .thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(appStateManager: mockAppStateManager),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Find delete button
      final deleteButton = find.byIcon(Icons.delete_outline);
      // TODO check

      // Tap delete button
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Check if confirmation dialog appears
      expect(find.text('确认删除'), findsOneWidget);
      expect(find.text('确定要删除这条专注记录吗？此操作不可恢复。'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);

      // Tap delete button in dialog
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      // Verify delete was called
      verify(() => mockAppStateManager.deleteFocusRecord('focus-1')).called(1);
    });

    testWidgets('should handle refresh functionality',
        (WidgetTester tester) async {
      final focusRecord = FocusRecord(
        id: 'focus-1',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 25),
        durationTarget: 25,
        durationFocus: 25,
        durationInterrupted: 0,
        isCompleted: true,
      );

      final session = FocusSession(
        focusRecord: focusRecord,
        focusTodos: [],
      );

      when(() => mockAppStateManager.getFocusRecords())
          .thenAnswer((_) async => [session]);

      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(appStateManager: mockAppStateManager),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Find refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      // Tap refresh button
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // Verify getFocusRecords was called again
      verify(() => mockAppStateManager.getFocusRecords()).called(2);
    });

    testWidgets('should handle error state gracefully',
        (WidgetTester tester) async {
      // Mock error
      when(() => mockAppStateManager.getFocusRecords())
          .thenThrow(Exception('Failed to load records'));

      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(appStateManager: mockAppStateManager),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Should show empty state instead of crashing
      expect(find.text('暂无统计数据'), findsOneWidget);
    });

    testWidgets('should display correct completion status',
        (WidgetTester tester) async {
      final completedRecord = FocusRecord(
        id: 'focus-1',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 25),
        durationTarget: 25,
        durationFocus: 25,
        durationInterrupted: 0,
        isCompleted: true,
      );

      final incompleteRecord = FocusRecord(
        id: 'focus-2',
        start: DateTime(2024, 1, 1, 11, 0),
        end: DateTime(2024, 1, 1, 11, 20),
        durationTarget: 30,
        durationFocus: 20,
        durationInterrupted: 10,
        isCompleted: true,
      );

      final sessions = [
        FocusSession(focusRecord: completedRecord, focusTodos: []),
        FocusSession(focusRecord: incompleteRecord, focusTodos: []),
      ];

      when(() => mockAppStateManager.getFocusRecords())
          .thenAnswer((_) async => sessions);

      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(appStateManager: mockAppStateManager),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Check completion status badges
      expect(find.text('已完成'), findsOneWidget);
      expect(find.text('未完成'), findsOneWidget);
    });

    testWidgets('should display todo information in record card',
        (WidgetTester tester) async {
      final focusRecord = FocusRecord(
        id: 'focus-1',
        start: DateTime(2024, 1, 1, 10, 0),
        end: DateTime(2024, 1, 1, 10, 25),
        durationTarget: 25,
        durationFocus: 25,
        durationInterrupted: 0,
        isCompleted: true,
      );

      final focusTodo = FocusTodo(
        id: 'todo-1',
        todoId: 'todo-123',
        focusId: 'focus-1',
        duration: 25,
        progressStart: 2,
        progressEnd: 5,
      );

      final session = FocusSession(
        focusRecord: focusRecord,
        focusTodos: [focusTodo],
      );

      when(() => mockAppStateManager.getFocusRecords())
          .thenAnswer((_) async => [session]);

      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(appStateManager: mockAppStateManager),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Check todo information
      expect(find.text('关联任务:'), findsOneWidget);
      expect(find.text('任务: todo-123...'), findsOneWidget);
      expect(find.text('进度提升: +3'), findsOneWidget);
      expect(find.text('专注: 25分钟'), findsOneWidget);
    });
  });
}
