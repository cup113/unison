import 'package:flutter/material.dart';
import 'dart:async';
import '../services/friends_service.dart';
import '../models/friend.dart';

class SocialTab extends StatefulWidget {
  const SocialTab({super.key});

  @override
  State<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<SocialTab> {
  List<Friend> _friends = [];
  final List<Map<String, dynamic>> _activities = []; // TODO make it a class
  Timer? _activityTimer;
  bool _isLoading = true;
  final FriendsService _friendsService = FriendsService();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _friendsService.getFriendsList();
      if (!mounted) return;

      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载好友列表失败: $e')),
      );
    }
  }

  void _showAddFriendDialog() {
    final TextEditingController userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加好友'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: '好友用户ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '请输入要添加的好友的用户ID',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (userIdController.text.isNotEmpty) {
                try {
                  await _friendsService
                      .sendFriendRequest(userIdController.text);
                  if (!mounted) return;
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('好友请求已发送')),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('发送好友请求失败: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('发送请求'),
          ),
        ],
      ),
    );
  }

  void _removeFriend(String friendId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除好友'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('确定要删除这个好友吗？'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: '原因（可选）',
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
            onPressed: () async {
              try {
                await _friendsService.refuseFriendRequest(
                    friendId, reasonController.text);
                setState(() {
                  _friends.removeWhere((friend) => friend.id == friendId);
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('好友已删除')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除好友失败: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptFriend(String friendRelationId) async {
    try {
      await _friendsService.approveFriendRequest(friendRelationId);
      if (!mounted) return;

      setState(() {
        final friend =
            _friends.firstWhere((f) => f.relationId == friendRelationId);
        friend.accepted = true;
        friend.acceptable = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('好友请求已接受')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('接受好友请求失败: $e')),
      );
    }
  }

  Future<void> _refuseFriend(String friendRelationId) async {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒绝好友请求'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('确定要拒绝这个好友请求吗？'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: '拒绝原因（可选）',
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
            onPressed: () async {
              try {
                await _friendsService.refuseFriendRequest(
                    friendRelationId, reasonController.text);
                if (!mounted) return;

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('好友请求已拒绝')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除好友失败: $e')),
                  );
                }
              }
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
          final refused = friend.refuseReason?.isNotEmpty;
          return Card(
            child: ListTile(
              title: Text(friend.name),
              subtitle: Text(friend.accepted
                  ? '已接受'
                  : (refused == true ? '已拒绝 ${friend.refuseReason}' : '等待接受')),
              trailing: friend.acceptable == true
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptFriend(friend.relationId),
                          tooltip: '接受好友请求',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _refuseFriend(friend.relationId),
                          tooltip: '拒绝好友请求',
                        ),
                      ],
                    )
                  : PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'remove') {
                          _removeFriend(friend.id);
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

  void _showFriendDetails(Friend friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(friend.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态: ${friend.accepted ? '已接受' : '等待接受'}'),
            if (friend.refuseReason != null && friend.refuseReason!.isNotEmpty)
              Text('拒绝原因: ${friend.refuseReason}'),
            if (friend.updated != null)
              Text('更新时间: ${friend.updated!.toLocal()}'),
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
