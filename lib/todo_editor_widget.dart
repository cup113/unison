import 'package:flutter/material.dart';
import 'todo.dart';
import 'todo_manager.dart';

class TodoEditorWidget extends StatefulWidget {
  final Todo? todo; // 如果为null，则为新建任务
  final TodoManager todoManager;
  final VoidCallback onTodoChanged;
  final VoidCallback onCancel;

  const TodoEditorWidget({
    super.key,
    this.todo,
    required this.todoManager,
    required this.onTodoChanged,
    required this.onCancel,
  });

  @override
  State<TodoEditorWidget> createState() => _TodoEditorWidgetState();
}

class _TodoEditorWidgetState extends State<TodoEditorWidget> {
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _estimatedTimeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.todo?.title ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.todo?.category ?? '',
    );
    _estimatedTimeController = TextEditingController(
      text: widget.todo?.estimatedTime.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.todo == null ? '添加新任务' : '编辑任务',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '任务标题',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: '类别',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _estimatedTimeController,
                  decoration: const InputDecoration(
                    labelText: '预计时间(分钟)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('取消'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saveTodo,
                child: Text(widget.todo == null ? '添加' : '保存'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveTodo() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入任务标题'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 验证预计时间
    int estimatedTime = 0;
    if (_estimatedTimeController.text.isNotEmpty) {
      final parsedTime = int.tryParse(_estimatedTimeController.text);
      if (parsedTime == null || parsedTime < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('预计时间必须是非负整数'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      estimatedTime = parsedTime;
    }

    if (widget.todo == null) {
      // 添加新任务
      widget.todoManager.addTodo(
        _titleController.text.trim(),
        category: _categoryController.text.trim(),
        estimatedTime: estimatedTime,
      );
    } else {
      // 更新现有任务
      widget.todoManager.updateTodo(
        widget.todo!.id,
        _titleController.text.trim(),
        category: _categoryController.text.trim(),
        estimatedTime: estimatedTime,
      );
    }

    widget.onTodoChanged();
  }
}
