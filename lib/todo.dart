class Todo {
  final String id;
  String title;
  int progress; // 0-10的进度值，替代原来的isCompleted
  bool isActive;
  String category; // 类别字段
  int estimatedTime; // 预计时间字段(以分钟为单位)

  Todo({
    required this.id,
    required this.title,
    this.progress = 0, // 默认进度为0
    this.isActive = false,
    this.category = '',
    this.estimatedTime = 0, // 0表示未设置预计时间
  });

  // 添加一个getter来判断任务是否完成(进度为10时完成)
  bool get isCompleted => progress == 10;

  Todo copyWith({
    String? id,
    String? title,
    int? progress,
    bool? isActive,
    String? category,
    int? estimatedTime,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }
}
