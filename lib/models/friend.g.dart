// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendAdapter extends TypeAdapter<Friend> {
  @override
  final int typeId = 7;

  @override
  Friend read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Friend(
      id: fields[0] as String,
      name: fields[1] as String,
      accepted: fields[3] as bool,
      relationId: fields[6] as String,
      updated: fields[2] as DateTime?,
      refuseReason: fields[4] as String?,
      acceptable: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Friend obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.updated)
      ..writeByte(3)
      ..write(obj.accepted)
      ..writeByte(4)
      ..write(obj.refuseReason)
      ..writeByte(5)
      ..write(obj.acceptable)
      ..writeByte(6)
      ..write(obj.relationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Friend _$FriendFromJson(Map<String, dynamic> json) => Friend(
      id: json['id'] as String,
      name: json['name'] as String,
      accepted: json['accepted'] as bool,
      relationId: json['relationId'] as String,
      updated: json['updated'] == null
          ? null
          : DateTime.parse(json['updated'] as String),
      refuseReason: json['refuseReason'] as String?,
      acceptable: json['acceptable'] as bool?,
    );

Map<String, dynamic> _$FriendToJson(Friend instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'updated': instance.updated?.toIso8601String(),
      'accepted': instance.accepted,
      'refuseReason': instance.refuseReason,
      'acceptable': instance.acceptable,
      'relationId': instance.relationId,
    };
