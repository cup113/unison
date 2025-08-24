import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'timer_state.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class TimerState {
  @HiveField(0)
  final int? selectedDuration; // 选定的持续时间（分钟）
  @HiveField(1)
  final int? remainingSeconds; // 剩余秒数
  @HiveField(2)
  final bool isPaused; // 是否暂停
  @HiveField(3)
  final int exitCount; // 退出次数
  @HiveField(4)
  final int pauseCount; // 暂停次数
  @HiveField(5)
  final DateTime? startTime; // 开始时间
  @HiveField(6)
  final DateTime? lastExitTime; // 上次退出时间

  TimerState({
    this.selectedDuration,
    this.remainingSeconds,
    this.isPaused = false,
    this.exitCount = 0,
    this.pauseCount = 0,
    this.startTime,
    this.lastExitTime,
  });

  TimerState copyWith({
    int? selectedDuration,
    int? remainingSeconds,
    bool? isPaused,
    int? exitCount,
    int? pauseCount,
    DateTime? startTime,
    DateTime? lastExitTime,
  }) {
    return TimerState(
      selectedDuration: selectedDuration ?? this.selectedDuration,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isPaused: isPaused ?? this.isPaused,
      exitCount: exitCount ?? this.exitCount,
      pauseCount: pauseCount ?? this.pauseCount,
      startTime: startTime ?? this.startTime,
      lastExitTime: lastExitTime ?? this.lastExitTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedDuration': selectedDuration,
      'remainingSeconds': remainingSeconds,
      'isPaused': isPaused,
      'exitCount': exitCount,
      'pauseCount': pauseCount,
      'startTime': startTime?.millisecondsSinceEpoch,
      'lastExitTime': lastExitTime?.millisecondsSinceEpoch,
    };
  }

  factory TimerState.fromMap(Map<String, dynamic> map) {
    return TimerState(
      selectedDuration: map['selectedDuration'],
      remainingSeconds: map['remainingSeconds'],
      isPaused: map['isPaused'] ?? false,
      exitCount: map['exitCount'] ?? 0,
      pauseCount: map['pauseCount'] ?? 0,
      startTime: map['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startTime'])
          : null,
      lastExitTime: map['lastExitTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastExitTime'])
          : null,
    );
  }

  factory TimerState.fromJson(Map<String, dynamic> json) => _$TimerStateFromJson(json);

  Map<String, dynamic> toJson() => _$TimerStateToJson(this);
}
