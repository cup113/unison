import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/todo_manager_interface.dart';
import 'todo_editor_widget.dart';
import '../providers.dart';

class TodoItemDisplayWidget extends ConsumerStatefulWidget {
  final Todo todo;
  final VoidCallback onTodoChanged;

  const TodoItemDisplayWidget({
    super.key,
    required this.todo,
    required this.onTodoChanged,
  });

  @override
  ConsumerState<TodoItemDisplayWidget> createState() =>
      _TodoItemDisplayWidgetState();
}

class _TodoItemDisplayWidgetState extends ConsumerState<TodoItemDisplayWidget> {
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
            widget.todo.title,
            style: TextStyle(
              decoration: widget.todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: widget.todo.isCompleted ? Colors.grey : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            widget.todo.isActive ? Icons.star : Icons.star_border,
            color: widget.todo.isActive ? Colors.orange : null,
          ),
          onPressed: () {
            final todoManager = ref.read(todoManagerProvider);
            todoManager.toggleActive(widget.todo.id);
            widget.onTodoChanged();
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
          icon: Icon(
            widget.todo.isArchived ? Icons.archive : Icons.archive_outlined,
            color: widget.todo.isArchived ? Colors.grey : null,
          ),
          onPressed: () {
            final todoManager = ref.read(todoManagerProvider);
            todoManager.toggleArchive(widget.todo.id);
            widget.onTodoChanged();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            final todoManager = ref.read(todoManagerProvider);
            todoManager.removeTodo(widget.todo.id);
            widget.onTodoChanged();
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
              todo: widget.todo,
              onTodoChanged: () {
                Navigator.of(context).pop();
                widget.onTodoChanged();
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
        // 显示已专注时间
        if (widget.todo.focusedTime > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 12, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '${widget.todo.focusedTime}分钟',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.todo.category.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.category, size: 12, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  widget.todo.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.todo.estimatedTime > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 12, color: Colors.deepOrange),
                const SizedBox(width: 4),
                Text(
                  '${widget.todo.estimatedTime}分钟',
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
              value: widget.todo.progress.toDouble(),
              min: 0,
              max: widget.todo.total.toDouble(),
              divisions: widget.todo.total,
              label: widget.todo.progress.toString(),
              onChanged: (value) {
                final todoManager = ref.read(todoManagerProvider);
                todoManager.setProgress(widget.todo.id, value.toInt());
                widget.onTodoChanged();
              },
            ),
          ),
        ),
        Text('${widget.todo.progress}/${widget.todo.total}'),
      ],
    );
  }
}
