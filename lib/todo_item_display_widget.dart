import 'package:flutter/material.dart';
import 'todo.dart';
import 'todo_manager.dart';
import 'todo_editor_widget.dart';

class TodoItemDisplayWidget extends StatelessWidget {
  final Todo todo;
  final TodoManager todoManager;
  final VoidCallback onTodoChanged;

  const TodoItemDisplayWidget({
    super.key,
    required this.todo,
    required this.todoManager,
    required this.onTodoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(context),
            const SizedBox(height: 4),
            _buildInfoRow(),
            _buildProgressRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: todo.isCompleted ? Colors.grey : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            todo.isActive ? Icons.star : Icons.star_border,
            color: todo.isActive ? Colors.orange : null,
          ),
          onPressed: () {
            todoManager.toggleActive(todo.id);
            onTodoChanged();
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // 在实际应用中，这里可以打开编辑界面
            _showEditDialog(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            todoManager.removeTodo(todo.id);
            onTodoChanged();
          },
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('编辑任务'),
          content: SizedBox(
            width: 300,
            child: TodoEditorWidget(
              todo: todo,
              todoManager: todoManager,
              onTodoChanged: () {
                Navigator.of(context).pop();
                onTodoChanged();
              },
              onCancel: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        // 显示进度值
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '进度: ${todo.progress}/10',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 显示已专注时间
        if (todo.focusedTime > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '专注: ${todo.focusedTime}分钟',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (todo.category.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              todo.category,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blueGrey,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (todo.estimatedTime > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${todo.estimatedTime}分钟',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressRow(BuildContext context) {
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
              value: todo.progress.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: todo.progress.toString(),
              onChanged: (value) {
                todoManager.setProgress(todo.id, value.toInt());
                onTodoChanged();
              },
            ),
          ),
        ),
        Text('${todo.progress}/10'),
      ],
    );
  }
}
