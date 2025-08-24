import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'todo.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class Todo {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  int progress; // 0-total的进度值，替代原来的isCompleted
  @HiveField(3)
  bool isActive;
  @HiveField(4)
  bool isArchived;
  @HiveField(5)
  String category; // 类别字段
  @HiveField(6)
  int estimatedTime; // 预计时间字段(以分钟为单位)
  @HiveField(7)
  int focusedTime; // 已专注时间字段(以分钟为单位)
  @HiveField(8)
  int total; // 进度总量，默认为 10

  Todo({
    required this.id,
    required this.title,
    this.progress = 0, // 默认进度为0
    this.isActive = false,
    this.isArchived = false,
    this.category = '',
    this.estimatedTime = 0, // 0表示未设置预计时间
    this.focusedTime = 0, // 默认专注时间为0
    this.total = 10, // 默认进度总量为10
  });

// 添加一个getter来判断任务是否完成(进度为total时完成)
  bool get isCompleted => progress == total;

  Todo copyWith({
    String? id,
    String? title,
    int? progress,
    bool? isActive,
    bool? isArchived,
    String? category,
    int? estimatedTime,
    int? focusedTime,
    int? total,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      category: category ?? this.category,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      focusedTime: focusedTime ?? this.focusedTime,
      total: total ?? this.total,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoToJson(this);
}
