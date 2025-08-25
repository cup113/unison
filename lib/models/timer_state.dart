import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'timer_state.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class TimerState {
  @HiveField(0)
  final int? selectedDuration; // 选定的持续时间，单位为分钟
  @HiveField(1)
  final int? remainingSeconds;
  @HiveField(2)
  final bool isPaused;
  @HiveField(3)
  final int exitCount;
  @HiveField(4)
  final int pauseCount;
  @HiveField(5)
  final DateTime? startTime;
  @HiveField(6)
  final DateTime? lastExitTime;
  @HiveField(7)
  final bool? isRest;

  TimerState({
    this.selectedDuration,
    this.remainingSeconds,
    this.isPaused = false,
    this.exitCount = 0,
    this.pauseCount = 0,
    this.startTime,
    this.lastExitTime,
    this.isRest = false,
  });

  TimerState copyWith({
    int? selectedDuration,
    int? remainingSeconds,
    bool? isPaused,
    int? exitCount,
    int? pauseCount,
    DateTime? startTime,
    DateTime? lastExitTime,
    bool? isRest,
  }) {
    return TimerState(
      selectedDuration: selectedDuration ?? this.selectedDuration,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isPaused: isPaused ?? this.isPaused,
      exitCount: exitCount ?? this.exitCount,
      pauseCount: pauseCount ?? this.pauseCount,
      startTime: startTime ?? this.startTime,
      lastExitTime: lastExitTime ?? this.lastExitTime,
      isRest: isRest ?? this.isRest,
    );
  }

  factory TimerState.fromJson(Map<String, dynamic> json) =>
      _$TimerStateFromJson(json);

  Map<String, dynamic> toJson() => _$TimerStateToJson(this);
}
