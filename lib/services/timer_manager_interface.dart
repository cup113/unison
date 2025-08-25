import '../models/focus.dart';
import 'package:flutter/foundation.dart';

abstract class TimerManagerInterface with ChangeNotifier {
  int? get selectedDuration;
  int? get remainingSeconds;
  int get exitCount;
  int get pauseCount;
  bool get isPaused;
  bool get isTimerActive;
  bool get isRest;
  DateTime? get startTime;
  DateTime? get lastExitTime;

  Future<void> loadFromStorage();
  Future<void> saveToStorage();

  Future<void> saveFocusRecord({
    required DateTime startTime,
    required DateTime endTime,
    required int plannedDuration,
    required int actualDuration,
    required int pauseCount,
    required int exitCount,
    required bool isCompleted,
    required String focusId,
    List<FocusTodo>? todoData,
  });

  Future<List<FocusSession>> getFocusRecords();
  Future<void> deleteFocusRecord(String id);

  void startTimer(int minutes);
  void resumeTimer();
  void pauseTimer();
  void cancelTimer(bool finished);
  void addTime(int minutes);
  void skipRest();
  void cancelRestTimer();
  void handleAppExit();
}
