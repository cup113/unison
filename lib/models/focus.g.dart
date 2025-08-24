// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusRecordAdapter extends TypeAdapter<FocusRecord> {
  @override
  final int typeId = 3;

  @override
  FocusRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusRecord(
      id: fields[0] as String,
      start: fields[1] as DateTime,
      end: fields[2] as DateTime,
      durationTarget: fields[3] as int,
      durationFocus: fields[4] as int,
      durationInterrupted: fields[5] as int,
      isCompleted: fields[6] as bool,
      userId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FocusRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.start)
      ..writeByte(2)
      ..write(obj.end)
      ..writeByte(3)
      ..write(obj.durationTarget)
      ..writeByte(4)
      ..write(obj.durationFocus)
      ..writeByte(5)
      ..write(obj.durationInterrupted)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FocusTodoAdapter extends TypeAdapter<FocusTodo> {
  @override
  final int typeId = 4;

  @override
  FocusTodo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusTodo(
      id: fields[0] as String,
      todoId: fields[1] as String,
      focusId: fields[2] as String,
      duration: fields[3] as int,
      progressStart: fields[4] as int,
      progressEnd: fields[5] as int,
      todoTitle: fields[6] as String?,
      todoCategory: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FocusTodo obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.todoId)
      ..writeByte(2)
      ..write(obj.focusId)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.progressStart)
      ..writeByte(5)
      ..write(obj.progressEnd)
      ..writeByte(6)
      ..write(obj.todoTitle)
      ..writeByte(7)
      ..write(obj.todoCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusTodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppUsageAdapter extends TypeAdapter<AppUsage> {
  @override
  final int typeId = 5;

  @override
  AppUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUsage(
      id: fields[0] as String,
      appName: fields[1] as String,
      start: fields[2] as DateTime,
      end: fields[3] as DateTime,
      duration: fields[4] as int,
      userId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppUsage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.end)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FocusSessionAdapter extends TypeAdapter<FocusSession> {
  @override
  final int typeId = 6;

  @override
  FocusSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSession(
      focusRecord: fields[0] as FocusRecord,
      focusTodos: (fields[1] as List).cast<FocusTodo>(),
      appUsages: (fields[2] as List?)?.cast<AppUsage>(),
    );
  }

  @override
  void write(BinaryWriter writer, FocusSession obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.focusRecord)
      ..writeByte(1)
      ..write(obj.focusTodos)
      ..writeByte(2)
      ..write(obj.appUsages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FocusRecord _$FocusRecordFromJson(Map<String, dynamic> json) => FocusRecord(
      id: json['id'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      durationTarget: (json['durationTarget'] as num).toInt(),
      durationFocus: (json['durationFocus'] as num).toInt(),
      durationInterrupted: (json['durationInterrupted'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$FocusRecordToJson(FocusRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'durationTarget': instance.durationTarget,
      'durationFocus': instance.durationFocus,
      'durationInterrupted': instance.durationInterrupted,
      'isCompleted': instance.isCompleted,
      'userId': instance.userId,
    };

FocusTodo _$FocusTodoFromJson(Map<String, dynamic> json) => FocusTodo(
      id: json['id'] as String,
      todoId: json['todoId'] as String,
      focusId: json['focusId'] as String,
      duration: (json['duration'] as num).toInt(),
      progressStart: (json['progressStart'] as num).toInt(),
      progressEnd: (json['progressEnd'] as num).toInt(),
      todoTitle: json['todoTitle'] as String?,
      todoCategory: json['todoCategory'] as String?,
    );

Map<String, dynamic> _$FocusTodoToJson(FocusTodo instance) => <String, dynamic>{
      'id': instance.id,
      'todoId': instance.todoId,
      'focusId': instance.focusId,
      'duration': instance.duration,
      'progressStart': instance.progressStart,
      'progressEnd': instance.progressEnd,
      'todoTitle': instance.todoTitle,
      'todoCategory': instance.todoCategory,
    };

AppUsage _$AppUsageFromJson(Map<String, dynamic> json) => AppUsage(
      id: json['id'] as String,
      appName: json['appName'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      duration: (json['duration'] as num).toInt(),
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$AppUsageToJson(AppUsage instance) => <String, dynamic>{
      'id': instance.id,
      'appName': instance.appName,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'duration': instance.duration,
      'userId': instance.userId,
    };

FocusSession _$FocusSessionFromJson(Map<String, dynamic> json) => FocusSession(
      focusRecord:
          FocusRecord.fromJson(json['focusRecord'] as Map<String, dynamic>),
      focusTodos: (json['focusTodos'] as List<dynamic>)
          .map((e) => FocusTodo.fromJson(e as Map<String, dynamic>))
          .toList(),
      appUsages: (json['appUsages'] as List<dynamic>?)
          ?.map((e) => AppUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FocusSessionToJson(FocusSession instance) =>
    <String, dynamic>{
      'focusRecord': instance.focusRecord.toJson(),
      'focusTodos': instance.focusTodos.map((e) => e.toJson()).toList(),
      'appUsages': instance.appUsages?.map((e) => e.toJson()).toList(),
    };
