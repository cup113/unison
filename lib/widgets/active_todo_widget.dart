import 'package:flutter/material.dart';
import '../services/todo_manager_interface.dart';
import '../models/todo.dart';

class ActiveTodoWidget extends StatefulWidget {
  final TodoManagerInterface todoManager;

  const ActiveTodoWidget({super.key, required this.todoManager});

  @override
  State<ActiveTodoWidget> createState() => _ActiveTodoWidgetState();
}

class _ActiveTodoWidgetState extends State<ActiveTodoWidget> {
  late TodoManagerInterface todoManager;

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
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
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
        if (activeTodo.isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
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
    );
  }

  Widget _buildTodoTags(Todo activeTodo) {
    final List<Widget> tags = [];

    if (activeTodo.category.isNotEmpty) {
      tags.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      );
    }

    if (activeTodo.estimatedTime > 0) {
      tags.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      );
    }

    if (tags.isNotEmpty) {
      return Row(
        children: [
          ...tags.expand((tag) => [tag, const SizedBox(width: 12)]).toList()
            ..removeLast(), // 移除最后一个SizedBox
        ],
      );
    }

    return const SizedBox.shrink();
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
              max: activeTodo.total.toDouble(),
              divisions: activeTodo.total,
              label: activeTodo.progress.toString(),
              onChanged: (value) {
                todoManager.setProgress(activeTodo.id, value.toInt());
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            const Icon(Icons.task, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '进度 ${activeTodo.progress}/${activeTodo.total}',
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  activeTodo.isCompleted ? Colors.grey[200] : Colors.green[50],
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
                const SizedBox(height: 8),
                _buildTodoTags(activeTodo),
                const SizedBox(height: 8),
                _buildProgressSlider(activeTodo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTodo = todoManager.getActiveTodo(includeCompleted: true);
    if (activeTodo == null) {
      return _buildNoActiveTodoView();
    }

    return _buildActiveTodoView(activeTodo);
  }
}
