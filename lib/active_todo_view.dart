import 'package:flutter/material.dart';
import 'todo_manager.dart';
import 'todo.dart';

class ActiveTodoView extends StatefulWidget {
  final TodoManager todoManager;

  const ActiveTodoView({super.key, required this.todoManager});

  @override
  State<ActiveTodoView> createState() => _ActiveTodoViewState();
}

class _ActiveTodoViewState extends State<ActiveTodoView> {
  late TodoManager todoManager;

  @override
  void initState() {
    super.initState();
    todoManager = widget.todoManager;
    // 添加监听器以更新UI
    todoManager.addListener(_updateUI);
  }

  @override
  void dispose() {
    // 移除监听器
    todoManager.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildNoActiveTodoView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
      child: Column(
        children: [
          const Text(
            '当前没有选中任务',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Text(
              '请在右上角的任务列表中选择一个任务作为当前专注任务',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoTitle(Todo activeTodo) {
    return Row(
      children: [
        Expanded(
          child: Text(
            activeTodo.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: activeTodo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
        if (activeTodo.isCompleted) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '已完成',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTodoTags(Todo activeTodo) {
    return Row(
      children: [
        if (activeTodo.category.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.category, size: 14, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  activeTodo.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (activeTodo.estimatedTime > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.deepOrange),
                const SizedBox(width: 4),
                Text(
                  '${activeTodo.estimatedTime}分钟',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSlider(Todo activeTodo) {
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.green,
              inactiveTrackColor: Colors.grey[300],
              thumbColor: Colors.green,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: activeTodo.progress.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: activeTodo.progress.toString(),
              onChanged: (value) {
                todoManager.setProgress(activeTodo.id, value.toInt());
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            const Icon(Icons.task, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '进度 ${activeTodo.progress}/10',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveTodoView(Todo activeTodo) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: activeTodo.isCompleted
                      ? Colors.grey[200]
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeTodo.isCompleted
                        ? Colors.grey.shade300
                        : Colors.green.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodoTitle(activeTodo),
                    const SizedBox(height: 12),
                    _buildTodoTags(activeTodo),
                    const SizedBox(height: 16),
                    _buildProgressSlider(activeTodo),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 使用 includeCompleted: true 来显示已完成但仍然活动的任务
    final activeTodo = todoManager.getActiveTodo(includeCompleted: true);
    if (activeTodo == null) {
      return _buildNoActiveTodoView();
    }

    return _buildActiveTodoView(activeTodo);
  }
}
