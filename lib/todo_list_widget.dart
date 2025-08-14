import 'package:flutter/material.dart';
import 'todo_manager.dart';
import 'todo_item_display_widget.dart';
import 'todo_editor_widget.dart';

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
  bool _isAddingTodo = false;

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
          if (_isAddingTodo)
            TodoEditorWidget(
              todoManager: widget.todoManager,
              onTodoChanged: _handleTodoChanged,
              onCancel: _cancelAddTodo,
            )
          else
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '点击下方按钮添加新任务',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _startAddTodo,
                  child: const Text('添加任务'),
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
                      return TodoItemDisplayWidget(
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

  void _startAddTodo() {
    setState(() {
      _isAddingTodo = true;
    });
  }

  void _cancelAddTodo() {
    setState(() {
      _isAddingTodo = false;
    });
  }

  void _handleTodoChanged() {
    setState(() {
      _isAddingTodo = false;
    });
    widget.onTodoChanged();
  }
}
