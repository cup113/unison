// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 1;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      id: fields[0] as String,
      title: fields[1] as String,
      progress: fields[2] as int,
      isActive: fields[3] as bool,
      isArchived: fields[4] as bool,
      category: fields[5] as String,
      estimatedTime: fields[6] as int,
      focusedTime: fields[7] as int,
      total: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.progress)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.isArchived)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.estimatedTime)
      ..writeByte(7)
      ..write(obj.focusedTime)
      ..writeByte(8)
      ..write(obj.total);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      category: json['category'] as String? ?? '',
      estimatedTime: (json['estimatedTime'] as num?)?.toInt() ?? 0,
      focusedTime: (json['focusedTime'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'progress': instance.progress,
      'isActive': instance.isActive,
      'isArchived': instance.isArchived,
      'category': instance.category,
      'estimatedTime': instance.estimatedTime,
      'focusedTime': instance.focusedTime,
      'total': instance.total,
    };
