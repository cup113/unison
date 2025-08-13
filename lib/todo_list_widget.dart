import 'package:flutter/material.dart';
import 'todo.dart';
import 'todo_manager.dart';

class TodoListWidget extends StatefulWidget {
  final TodoManager todoManager;
  final VoidCallback onTodoChanged;

  const TodoListWidget({
    super.key,
    required this.todoManager,
    required this.onTodoChanged,
  });

  @override
  State<TodoListWidget> createState() => _TodoListWidgetState();
}

class _TodoListWidgetState extends State<TodoListWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _estimatedTimeController =
      TextEditingController();

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
          const Text(
            '任务列表',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: '任务标题...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    hintText: '类别...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _estimatedTimeController,
                  decoration: const InputDecoration(
                    hintText: '预计时间(分钟)...',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isNotEmpty) {
                    // 修改：验证预计时间是否为有效数字
                    int estimatedTime = 0;
                    if (_estimatedTimeController.text.isNotEmpty) {
                      final parsedTime =
                          int.tryParse(_estimatedTimeController.text);
                      if (parsedTime == null || parsedTime <= 0) {
                        // 如果输入的不是有效数字，显示错误提示
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('预计时间必须是大于0的整数'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      estimatedTime = parsedTime;
                    }

                    widget.todoManager.addTodo(
                      _titleController.text.trim(),
                      category: _categoryController.text.trim(),
                      estimatedTime: estimatedTime,
                    );
                    _titleController.clear();
                    _categoryController.clear();
                    _estimatedTimeController.clear();
                    widget.onTodoChanged();
                  }
                },
                child: const Text('添加'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.todoManager.todos.isEmpty
                ? const Center(
                    child: Text(
                      '暂无任务，请添加新任务',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.todoManager.todos.length,
                    itemBuilder: (context, index) {
                      final todo = widget.todoManager.todos[index];
                      return TodoItemWidget(
                        todo: todo,
                        todoManager: widget.todoManager,
                        onTodoChanged: widget.onTodoChanged,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TodoItemWidget extends StatefulWidget {
  final Todo todo;
  final TodoManager todoManager;
  final VoidCallback onTodoChanged;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.todoManager,
    required this.onTodoChanged,
  });

  @override
  State<TodoItemWidget> createState() => _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget> {
  late TextEditingController _editTitleController;
  late TextEditingController _editCategoryController;
  late TextEditingController _editEstimatedTimeController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _editTitleController = TextEditingController(text: widget.todo.title);
    _editCategoryController = TextEditingController(text: widget.todo.category);
    _editEstimatedTimeController = TextEditingController(
      text: widget.todo.estimatedTime.toString(),
    );
  }

  @override
  void dispose() {
    _editTitleController.dispose();
    _editCategoryController.dispose();
    _editEstimatedTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(),
            if (_isEditing) _buildEditFields(),
            const SizedBox(height: 4),
            _buildInfoRow(),
            _buildProgressRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        // 标题和编辑框
        Expanded(
          child: _isEditing
              ? TextField(
                  controller: _editTitleController,
                  decoration: const InputDecoration(
                    hintText: '标题',
                    border: OutlineInputBorder(),
                  ),
                )
              : Text(
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
        // 操作按钮
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                widget.todo.isActive ? Icons.star : Icons.star_border,
                color: widget.todo.isActive ? Colors.orange : null,
              ),
              onPressed: () {
                widget.todoManager.toggleActive(widget.todo.id);
                widget.onTodoChanged();
              },
            ),
            if (!_isEditing) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  widget.todoManager.removeTodo(widget.todo.id);
                  widget.onTodoChanged();
                },
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveEdit,
              ),
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: _cancelEdit,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildEditFields() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _editCategoryController,
                decoration: const InputDecoration(
                  hintText: '类别',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _editEstimatedTimeController,
                decoration: const InputDecoration(
                  hintText: '预计时间(分钟)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
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
            '进度: ${widget.todo.progress}/10',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 8),
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
            child: Text(
              widget.todo.category,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blueGrey,
              ),
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
            child: Text(
              '${widget.todo.estimatedTime}分钟',
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

  Widget _buildProgressRow() {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: widget.todo.progress.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: widget.todo.progress.toString(),
            onChanged: (value) {
              widget.todoManager.setProgress(widget.todo.id, value.toInt());
              widget.onTodoChanged();
            },
          ),
        ),
        Text('${widget.todo.progress}/10'),
      ],
    );
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editTitleController.text = widget.todo.title;
      _editCategoryController.text = widget.todo.category;
      _editEstimatedTimeController.text = widget.todo.estimatedTime.toString();
    });
  }

  void _saveEdit() {
    if (_editTitleController.text.trim().isNotEmpty) {
      // 验证预计时间是否为有效数字
      int estimatedTime = widget.todo.estimatedTime;
      if (_editEstimatedTimeController.text.isNotEmpty) {
        final parsedTime = int.tryParse(_editEstimatedTimeController.text);
        if (parsedTime == null || parsedTime < 0) {
          // 如果输入的不是有效数字，显示错误提示
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

      widget.todoManager.updateTodo(
        widget.todo.id,
        _editTitleController.text.trim(),
        category: _editCategoryController.text.trim(),
        estimatedTime: estimatedTime,
      );
      widget.onTodoChanged();
    }
    setState(() {
      _isEditing = false;
    });
  }
}
