import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'todo.dart';
import 'todo_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Co-Progress',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const FocusTimerPage(),
    );
  }
}

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage>
    with WidgetsBindingObserver {
  static const List<int> presetDurations = [25, 40, 60, 90]; // in minutes
  int? _selectedDuration;
  int? _remainingSeconds;
  Timer? _timer;
  int _exitCount = 0;
  bool _isPaused = false;
  final TodoManager _todoManager = TodoManager();
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExitCount();
    WidgetsBinding.instance.addObserver(this);
    _todoManager.addListener(_handleTodoChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _todoManager.removeListener(_handleTodoChange);
    _todoController.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _handleTodoChange() {
    setState(() {});
  }

  void _loadExitCount() {
    // In a real app, you would load this from shared preferences or a database
    // For now, we'll just initialize it to 0
    setState(() {
      _exitCount = 0;
    });
  }

  void _incrementExitCount() {
    setState(() {
      _exitCount++;
    });
    // In a real app, you would save this to shared preferences or a database
  }

  void _startTimer(int minutes) {
    setState(() {
      _selectedDuration = minutes;
      _remainingSeconds = minutes * 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds! > 0) {
          _remainingSeconds = _remainingSeconds! - 1;
        } else {
          _timer?.cancel();
          _showTimerCompleteDialog();
        }
      });
    });
  }

  void _showTimerCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('专注完成'),
          content: const Text('恭喜你完成专注任务！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedDuration = null;
                  _remainingSeconds = null;
                });
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    if (_remainingSeconds != null && _remainingSeconds! > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds! > 0) {
            _remainingSeconds = _remainingSeconds! - 1;
          } else {
            _timer?.cancel();
            _showTimerCompleteDialog();
          }
          _isPaused = false;
        });
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      if (_remainingSeconds != null && _remainingSeconds! > 0) {
        _incrementExitCount();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }

        // 不再在返回时增加退出计数
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Co-Progress 专注计时器'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(icon: const Icon(Icons.list), onPressed: _showTodoList),
          ],
        ),
        body: Center(
          child: _remainingSeconds == null
              ? _buildSetupView()
              : _buildTimerView(),
        ),
      ),
    );
  }

  Widget _buildSetupView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '选择专注时长',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: presetDurations.map((minutes) {
            return ElevatedButton(
              onPressed: () => _startTimer(minutes),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: Text('$minutes分钟'),
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        Text(
          '退出次数: $_exitCount',
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
        const SizedBox(height: 20),
        _buildActiveTodo(),
      ],
    );
  }

  Widget _buildTimerView() {
    final minutes = (_remainingSeconds! / 60).floor();
    final seconds = _remainingSeconds! % 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (_timer?.isActive ?? false) {
                  _pauseTimer();
                } else {
                  _resumeTimer();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(_isPaused ? '继续' : '暂停'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                setState(() {
                  _selectedDuration = null;
                  _remainingSeconds = null;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('取消'),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          '$_selectedDuration分钟专注中...',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Text(
          '退出次数: $_exitCount',
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
        const SizedBox(height: 20),
        _buildActiveTodo(),
      ],
    );
  }

  Widget _buildActiveTodo() {
    final activeTodo = _todoManager.getActiveTodo();
    if (activeTodo == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('当前任务:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(activeTodo.title, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showTodoList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              constraints: const BoxConstraints(maxHeight: 500),
              child: TodoListWidget(
                todoManager: _todoManager,
                onTodoChanged: () => setState(() {}),
              ),
            );
          },
        );
      },
    );
  }
}

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
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
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
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '添加新任务...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    widget.todoManager.addTodo(_controller.text.trim());
                    _controller.clear();
                    widget.onTodoChanged();
                  }
                },
                child: const Text('添加'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
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
  late TextEditingController _editController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.todo.title);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                widget.todo.isCompleted
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: widget.todo.isCompleted ? Colors.green : null,
              ),
              onPressed: () {
                widget.todoManager.toggleCompleted(widget.todo.id);
                widget.onTodoChanged();
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _isEditing
                  ? TextField(
                      controller: _editController,
                      onSubmitted: (_) => _saveEdit(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    )
                  : Text(
                      widget.todo.title,
                      style: TextStyle(
                        decoration: widget.todo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: widget.todo.isCompleted ? Colors.grey : null,
                      ),
                    ),
            ),
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
              IconButton(icon: const Icon(Icons.save), onPressed: _saveEdit),
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _editController.text = widget.todo.title;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveEdit() {
    if (_editController.text.trim().isNotEmpty) {
      widget.todoManager.updateTodo(
        widget.todo.id,
        _editController.text.trim(),
      );
      widget.onTodoChanged();
    }
    setState(() {
      _isEditing = false;
    });
  }
}
