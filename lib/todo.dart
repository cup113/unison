class Todo {
  final String id;
  String title;
  bool isCompleted;
  bool isActive;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isActive = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    bool? isActive,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
    );
  }
}
