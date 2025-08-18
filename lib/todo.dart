class Todo {
  final String id;
  String title;
  int progress; // 0-total的进度值，替代原来的isCompleted
  bool isActive;
  bool isArchived;
  String category; // 类别字段
  int estimatedTime; // 预计时间字段(以分钟为单位)
  int focusedTime; // 已专注时间字段(以分钟为单位)
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
}
