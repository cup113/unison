import 'package:nanoid2/nanoid2.dart';

class FocusRecord {
  final String id;
  final DateTime start;
  final DateTime end;
  final int durationTarget; // 目标时长（分钟）
  final int durationFocus; // 实际专注时长（分钟）
  final int durationInterrupted; // 中断时长（分钟）
  final bool isCompleted; // 显式完成状态，由用户操作指定
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'durationTarget': durationTarget,
      'durationFocus': durationFocus,
      'durationInterrupted': durationInterrupted,
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }

  factory FocusRecord.fromMap(Map<String, dynamic> map) {
    return FocusRecord(
      id: map['id'] ?? nanoid(),
      start: map['start'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['start'])
          : DateTime.now(),
      end: map['end'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end'])
          : DateTime.now(),
      durationTarget: map['durationTarget'] ?? 0,
      durationFocus: map['durationFocus'] ?? 0,
      durationInterrupted: map['durationInterrupted'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'],
    );
  }

  FocusRecord copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    int? durationTarget,
    int? durationFocus,
    int? durationInterrupted,
    bool? isCompleted,
    String? userId,
  }) {
    return FocusRecord(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      durationTarget: durationTarget ?? this.durationTarget,
      durationFocus: durationFocus ?? this.durationFocus,
      durationInterrupted: durationInterrupted ?? this.durationInterrupted,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
    );
  }
}

class FocusTodo {
  final String id;
  final String todoId; // 关联的Todo ID
  final String focusId; // 关联的Focus ID
  final int duration; // 专注时长（分钟）
  final int progressStart; // 开始时的进度
  final int progressEnd; // 结束时的进度
  final String? todoTitle; // 标题（用于显示）
  final String? todoCategory; // 类别（用于显示）

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todoId': todoId,
      'focusId': focusId,
      'duration': duration,
      'progressStart': progressStart,
      'progressEnd': progressEnd,
      'todoTitle': todoTitle,
      'todoCategory': todoCategory,
    };
  }

  factory FocusTodo.fromMap(Map<String, dynamic> map) {
    return FocusTodo(
      id: map['id'] ?? nanoid(),
      todoId: map['todoId'] ?? '',
      focusId: map['focusId'] ?? '',
      duration: map['duration'] ?? 0,
      progressStart: map['progressStart'] ?? 0,
      progressEnd: map['progressEnd'] ?? 0,
      todoTitle: map['todoTitle'],
      todoCategory: map['todoCategory'],
    );
  }

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
}

class AppUsage {
  final String id;
  final String appName; // 应用名称
  final DateTime start; // 开始时间
  final DateTime end; // 结束时间
  final int duration; // 使用时长（分钟）
  final String? userId; // 用户ID，用于服务端同步

  AppUsage({
    required this.id,
    required this.appName,
    required this.start,
    required this.end,
    required this.duration,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appName': appName,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'duration': duration,
      'userId': userId,
    };
  }

  factory AppUsage.fromMap(Map<String, dynamic> map) {
    return AppUsage(
      id: map['id'] ?? nanoid(),
      appName: map['appName'] ?? '',
      start: map['start'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['start'])
          : DateTime.now(),
      end: map['end'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end'])
          : DateTime.now(),
      duration: map['duration'] ?? 0,
      userId: map['userId'],
    );
  }

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
}

// 专注会话数据传输对象，用于整合FocusRecord和相关的FocusTodo
class FocusSession {
  final FocusRecord focusRecord;
  final List<FocusTodo> focusTodos;
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

  Map<String, dynamic> toMap() {
    return {
      'focusRecord': focusRecord.toMap(),
      'focusTodos': focusTodos.map((ft) => ft.toMap()).toList(),
      'appUsages': appUsages?.map((au) => au.toMap()).toList(),
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      focusRecord: FocusRecord.fromMap(map['focusRecord'] ?? {}),
      focusTodos: (map['focusTodos'] as List<dynamic>?)
              ?.map((ft) => FocusTodo.fromMap(ft))
              .toList() ??
          [],
      appUsages: (map['appUsages'] as List<dynamic>?)
          ?.map((au) => AppUsage.fromMap(au))
          .toList(),
    );
  }

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
}
