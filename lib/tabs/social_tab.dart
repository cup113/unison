import 'package:flutter/material.dart';
import 'dart:async';
import '../app_state_manager.dart';

class SocialTab extends StatefulWidget {
  final AppStateManager appStateManager;

  const SocialTab({super.key, required this.appStateManager});

  @override
  State<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<SocialTab> {
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _activities = [];
  Timer? _activityTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _startActivitySimulation();
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    // Simulate loading friends from storage/server
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _friends = [
        {
          'id': '1',
          'name': '张三',
          'status': '专注中',
          'focusTime': 25,
          'isOnline': true,
        },
        {
          'id': '2',
          'name': '李四',
          'status': '休息中',
          'focusTime': 0,
          'isOnline': true,
        },
        {
          'id': '3',
          'name': '王五',
          'status': '离线',
          'focusTime': 0,
          'isOnline': false,
        },
      ];
      _isLoading = false;
    });
  }

  void _startActivitySimulation() {
    // Simulate activity updates every 6 seconds (10 times per minute)
    _activityTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        _addRandomActivity();
      }
    });
  }

  void _addRandomActivity() {
    if (!mounted) return;

    final activities = [
      {'type': 'focus_start', 'message': '开始专注', 'icon': '🎯'},
      {'type': 'focus_complete', 'message': '完成专注', 'icon': '✅'},
      {'type': 'task_complete', 'message': '完成任务', 'icon': '📋'},
      {'type': 'achievement', 'message': '获得成就', 'icon': '🏆'},
    ];

    if (_friends.isNotEmpty) {
      final randomFriend =
          _friends[DateTime.now().millisecond % _friends.length];
      final randomActivity =
          activities[DateTime.now().second % activities.length];

      setState(() {
        _activities.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'friend': randomFriend,
          'activity': randomActivity,
          'timestamp': DateTime.now(),
        });

        // Keep only last 50 activities
        if (_activities.length > 50) {
          _activities = _activities.take(50).toList();
        }
      });
    }
  }

  void _showAddFriendDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController statusController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加好友'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '好友名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: statusController,
              decoration: const InputDecoration(
                labelText: '状态消息',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                if (!mounted) return;
                setState(() {
                  _friends.add({
                    'id': DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(), // TODO mock
                    'name': nameController.text,
                    'status': statusController.text.isNotEmpty
                        ? statusController.text
                        : '在线',
                    'focusTime': 0,
                    'isOnline': true,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _removeFriend(String friendId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个好友吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _friends.removeWhere((friend) => friend['id'] == friendId);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('社交'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: '好友'),
              Tab(text: '动态'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showAddFriendDialog,
              tooltip: '添加好友',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildFriendsList(),
            _buildActivityFeed(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '还没有好友',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '点击右上角添加好友',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriends,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return Card(
            child: ListTile(
              title: Text(friend['name']),
              subtitle: Text(friend['status']),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeFriend(friend['id']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('删除好友'),
                  ),
                ],
              ),
              onTap: () {
                _showFriendDetails(friend);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityFeed() {
    if (_activities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '暂无动态',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '好友活动将在这里显示',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (!mounted) return;
        setState(() {
          _activities.clear();
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          final friend = activity['friend'];
          final activityData = activity['activity'];
          final timestamp = activity['timestamp'];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  activityData['icon'],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              title: Text('${friend['name']} ${activityData['message']}'),
              subtitle: Text(
                _formatTimestamp(timestamp),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: friend['isOnline']
                  ? const Icon(Icons.circle, color: Colors.green, size: 12)
                  : const Icon(Icons.circle, color: Colors.grey, size: 12),
            ),
          );
        },
      ),
    );
  }

  void _showFriendDetails(Map<String, dynamic> friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(friend['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend['isOnline'] ? '在线' : '离线',
                      style: TextStyle(
                        color: friend['isOnline'] ? Colors.green : Colors.grey,
                      ),
                    ),
                    Text(friend['status']),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('今日专注: ${friend['focusTime']} 分钟'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小时前';
    } else {
      return '${difference.inDays} 天前';
    }
  }
}
