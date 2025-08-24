import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'friend.g.dart';

@JsonSerializable()
@HiveType(typeId: 7)
class Friend {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  DateTime? updated;
  @HiveField(3)
  bool accepted;
  @HiveField(4)
  String? refuseReason;
  @HiveField(5)
  bool? acceptable;
  @HiveField(6)
  String relationId;

  Friend({
    required this.id,
    required this.name,
    required this.accepted,
    required this.relationId,
    this.updated,
    this.refuseReason,
    this.acceptable,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);

  Map<String, dynamic> toJson() => _$FriendToJson(this);
}
