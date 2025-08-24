// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimerStateAdapter extends TypeAdapter<TimerState> {
  @override
  final int typeId = 2;

  @override
  TimerState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerState(
      selectedDuration: fields[0] as int?,
      remainingSeconds: fields[1] as int?,
      isPaused: fields[2] as bool,
      exitCount: fields[3] as int,
      pauseCount: fields[4] as int,
      startTime: fields[5] as DateTime?,
      lastExitTime: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TimerState obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.selectedDuration)
      ..writeByte(1)
      ..write(obj.remainingSeconds)
      ..writeByte(2)
      ..write(obj.isPaused)
      ..writeByte(3)
      ..write(obj.exitCount)
      ..writeByte(4)
      ..write(obj.pauseCount)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.lastExitTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimerState _$TimerStateFromJson(Map<String, dynamic> json) => TimerState(
      selectedDuration: (json['selectedDuration'] as num?)?.toInt(),
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt(),
      isPaused: json['isPaused'] as bool? ?? false,
      exitCount: (json['exitCount'] as num?)?.toInt() ?? 0,
      pauseCount: (json['pauseCount'] as num?)?.toInt() ?? 0,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      lastExitTime: json['lastExitTime'] == null
          ? null
          : DateTime.parse(json['lastExitTime'] as String),
    );

Map<String, dynamic> _$TimerStateToJson(TimerState instance) =>
    <String, dynamic>{
      'selectedDuration': instance.selectedDuration,
      'remainingSeconds': instance.remainingSeconds,
      'isPaused': instance.isPaused,
      'exitCount': instance.exitCount,
      'pauseCount': instance.pauseCount,
      'startTime': instance.startTime?.toIso8601String(),
      'lastExitTime': instance.lastExitTime?.toIso8601String(),
    };
