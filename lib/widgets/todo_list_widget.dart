import 'package:flutter/material.dart';
import '../services/todo_manager_interface.dart';
import 'todo_item_display_widget.dart';
import 'todo_editor_widget.dart';

class TodoListWidget extends StatefulWidget {
  final TodoManagerInterface todoManager;
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
  void initState() {
    super.initState();
    widget.todoManager.addListener(_onTodoChanged);
  }

  @override
  void dispose() {
    widget.todoManager.removeListener(_onTodoChanged);
    super.dispose();
  }

  void _onTodoChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildAddTodoSection(),
          const SizedBox(height: 16),
          _buildTodoList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      '任务列表',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAddTodoSection() {
    if (_isAddingTodo) {
      return TodoEditorWidget(
        todoManager: widget.todoManager,
        onTodoChanged: _handleTodoChanged,
        onCancel: _cancelAddTodo,
      );
    }
    return Row(
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
    );
  }

  Widget _buildTodoList() {
    return Expanded(
      child: widget.todoManager.todos.isEmpty
          ? _buildEmptyState()
          : _buildTodoListView(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        '暂无任务，请添加新任务',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildTodoListView() {
    return ListView(
      children: [
        // 未归档的任务
        ...widget.todoManager.notArchivedTodos.map(
          (todo) => TodoItemDisplayWidget(
            todo: todo,
            todoManager: widget.todoManager,
            onTodoChanged: widget.onTodoChanged,
          ),
        ),

        // 已归档的任务标题
        if (widget.todoManager.archivedTodos.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '已归档',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          // 已归档的任务列表
          ...widget.todoManager.archivedTodos.map(
            (todo) => TodoItemDisplayWidget(
              todo: todo,
              todoManager: widget.todoManager,
              onTodoChanged: widget.onTodoChanged,
            ),
          ),
        ],
      ],
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('任务列表已更新'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }
}
