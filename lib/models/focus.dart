import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'focus.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)
class FocusRecord {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime start;
  @HiveField(2)
  final DateTime end;
  @HiveField(3)
  final int durationTarget; // 目标时长（分钟）
  @HiveField(4)
  final int durationFocus; // 实际专注时长（分钟）
  @HiveField(5)
  final int durationInterrupted; // 中断时长（分钟）
  @HiveField(6)
  final bool isCompleted; // 显式完成状态，由用户操作指定
  @HiveField(7)
  final String? userId; // 用户ID，用于服务端同步

  FocusRecord({
    required this.id,
    required this.start,
    required this.end,
    required this.durationTarget,
    required this.durationFocus,
    required this.durationInterrupted,
    required this.isCompleted,
    this.userId,
  });

  // 计算专注时长（秒）
  int get durationFocusSeconds => durationFocus * 60;

  // 计算中断时长（秒）
  int get durationInterruptedSeconds => durationInterrupted * 60;

  // 计算目标时长（秒）
  int get durationTargetSeconds => durationTarget * 60;

  // 计算完成率（基于实际专注时长）
  double get completionRate =>
      durationTarget > 0 ? (durationFocus / durationTarget) * 100 : 0;

  factory FocusRecord.fromJson(Map<String, dynamic> json) =>
      _$FocusRecordFromJson(json);

  Map<String, dynamic> toJson() => _$FocusRecordToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 4)
class FocusTodo {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String todoId;
  @HiveField(2)
  final String focusId;
  @HiveField(3)
  final int duration;
  @HiveField(4)
  final int progressStart;
  @HiveField(5)
  final int progressEnd;
  @HiveField(6)
  final String? todoTitle;
  @HiveField(7)
  final String? todoCategory;

  FocusTodo({
    required this.id,
    required this.todoId,
    required this.focusId,
    required this.duration,
    required this.progressStart,
    required this.progressEnd,
    this.todoTitle,
    this.todoCategory,
  });

  // 计算进度提升
  int get progressImprovement => progressEnd - progressStart;

  FocusTodo copyWith({
    String? id,
    String? todoId,
    String? focusId,
    int? duration,
    int? progressStart,
    int? progressEnd,
    String? todoTitle,
    String? todoCategory,
  }) {
    return FocusTodo(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      focusId: focusId ?? this.focusId,
      duration: duration ?? this.duration,
      progressStart: progressStart ?? this.progressStart,
      progressEnd: progressEnd ?? this.progressEnd,
      todoTitle: todoTitle ?? this.todoTitle,
      todoCategory: todoCategory ?? this.todoCategory,
    );
  }

  factory FocusTodo.fromJson(Map<String, dynamic> json) =>
      _$FocusTodoFromJson(json);

  Map<String, dynamic> toJson() => _$FocusTodoToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 5)
class AppUsage {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String appName;
  @HiveField(2)
  final DateTime start;
  @HiveField(3)
  final DateTime end;
  @HiveField(4)
  final int duration;
  @HiveField(5)
  final String? userId;

  AppUsage({
    required this.id,
    required this.appName,
    required this.start,
    required this.end,
    required this.duration,
    this.userId,
  });

  AppUsage copyWith({
    String? id,
    String? appName,
    DateTime? start,
    DateTime? end,
    int? duration,
    String? userId,
  }) {
    return AppUsage(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      start: start ?? this.start,
      end: end ?? this.end,
      duration: duration ?? this.duration,
      userId: userId ?? this.userId,
    );
  }

  factory AppUsage.fromJson(Map<String, dynamic> json) =>
      _$AppUsageFromJson(json);

  Map<String, dynamic> toJson() => _$AppUsageToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 6)
class FocusSession {
  @HiveField(0)
  final FocusRecord focusRecord;
  @HiveField(1)
  final List<FocusTodo> focusTodos;
  @HiveField(2)
  final List<AppUsage>? appUsages; // 可选的应用使用记录

  FocusSession({
    required this.focusRecord,
    required this.focusTodos,
    this.appUsages,
  });

  // 获取总专注时长
  int get totalDuration => focusRecord.durationFocus;

  // 获取关联的Todo数量
  int get todoCount => focusTodos.length;

  // 获取平均进度提升
  double get averageProgressImprovement => focusTodos.isEmpty
      ? 0
      : focusTodos.fold(0, (sum, ft) => sum + ft.progressImprovement) /
          focusTodos.length;

  FocusSession copyWith({
    FocusRecord? focusRecord,
    List<FocusTodo>? focusTodos,
    List<AppUsage>? appUsages,
  }) {
    return FocusSession(
      focusRecord: focusRecord ?? this.focusRecord,
      focusTodos: focusTodos ?? this.focusTodos,
      appUsages: appUsages ?? this.appUsages,
    );
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) =>
      _$FocusSessionFromJson(json);

  Map<String, dynamic> toJson() => _$FocusSessionToJson(this);
}
