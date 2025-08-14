import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_state_manager.dart';

class StatisticsPage extends StatefulWidget {
  final AppStateManager appStateManager;

  const StatisticsPage({super.key, required this.appStateManager});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _records = await widget.appStateManager.getFocusRecords();
      // 按时间倒序排列
      _records.sort((a, b) => b['startTime'].compareTo(a['startTime']));
    } catch (e) {
      // 错误处理
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('加载统计数据失败')));
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计数据'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRecords),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(
                  child: Text(
                    '暂无统计数据\n完成专注任务后将在此显示统计数据',
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecords,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 20),
                      _buildSevenDaysChangeCard(),
                      const SizedBox(height: 20),
                      const Text(
                        '专注历史',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      for (var record in _records) _buildRecordCard(record),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard() {
    // 计算统计数据
    int totalSessions = _records.length;
    int totalMinutes = _records.fold(
      0,
      (sum, record) => (sum + record['actualDuration']) as int,
    );
    int totalPlannedMinutes = _records.fold(
      0,
      (sum, record) => (sum + record['plannedDuration']) as int,
    );
    double completionRate = totalSessions > 0
        ? _records
                .where((record) =>
                    record['actualDuration'] >= record['plannedDuration'] * 0.9)
                .length /
            totalSessions *
            100
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '总览',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStatRow('专注次数', '$totalSessions 次'),
            _buildStatRow('专注时长', '$totalMinutes 分钟'),
            _buildStatRow('计划时长', '$totalPlannedMinutes 分钟'),
            _buildStatRow('完成率', '${completionRate.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildSevenDaysChangeCard() {
    // 过去7天的数据
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final recentRecords = _records.where((record) {
      final recordTime =
          DateTime.fromMillisecondsSinceEpoch(record['startTime']);
      return recordTime.isAfter(sevenDaysAgo);
    }).toList();

    int recentSessions = recentRecords.length;
    int recentMinutes = recentRecords.fold(
      0,
      (sum, record) => (sum + record['actualDuration']) as int,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '近7天',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStatRow('专注次数', '$recentSessions 次'),
            _buildStatRow('专注时长', '$recentMinutes 分钟'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final startTime = DateTime.fromMillisecondsSinceEpoch(record['startTime']);
    final endTime = DateTime.fromMillisecondsSinceEpoch(record['endTime']);
    final plannedDuration = record['plannedDuration'];
    final actualDuration = record['actualDuration'];
    final pauseCount = record['pauseCount'] ?? 0;
    final exitCount = record['exitCount'] ?? 0;
    final todoData = record['todoData']; // 现在是列表形式

    bool isCompleted = actualDuration >= plannedDuration * 0.9;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat('MM-dd HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? '已完成' : '未完成',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildRecordStatRow('计划时长', '$plannedDuration 分钟'),
            _buildRecordStatRow('实际时长', '$actualDuration 分钟'),
            _buildRecordStatRow('暂停次数', '$pauseCount 次'),
            _buildRecordStatRow('退出次数', '$exitCount 次'),
            if (todoData != null && todoData is List) ...[
              const SizedBox(height: 4),
              const Text(
                '关联任务:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (var todo in todoData) _buildTodoInfoRow(todo),
            ] else if (todoData != null && todoData is Map) ...[
              // 兼容旧数据格式
              const SizedBox(height: 4),
              const Text(
                '关联任务:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildTodoInfoRow(Map<String, dynamic>.from(todoData)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTodoInfoRow(Map<String, dynamic> todo) {
    final todoTitle = todo['todoTitle'];
    final todoProgress = todo['todoProgress'];
    final todoFocusedTime = todo['todoFocusedTime'];

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              todoTitle ?? '未知任务',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (todoProgress != null)
            Text(
              '进度: $todoProgress/10',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          if (todoFocusedTime != null) ...[
            const SizedBox(width: 8),
            Text(
              '专注: $todoFocusedTime分钟',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ],
      ),
    );
  }
}
