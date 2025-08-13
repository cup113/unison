import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timer_manager.dart';

class StatisticsPage extends StatefulWidget {
  final TimerManager timerManager;

  const StatisticsPage({super.key, required this.timerManager});

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
      _records = await widget.timerManager.getFocusRecords();
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  .where(
                    (record) =>
                        record['actualDuration'] >=
                        record['plannedDuration'] * 0.9,
                  )
                  .length /
              totalSessions
        : 0.0;

    int totalPauseCount = _records.fold(
      0,
      (sum, record) => sum + (record['pauseCount'] ?? 0) as int,
    );
    int totalExitCount = _records.fold(
      0,
      (sum, record) => sum + (record['exitCount'] ?? 0) as int,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '总体统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStatRow('专注次数', '$totalSessions 次'),
            _buildStatRow(
              '专注时长',
              '${(totalMinutes / 60).toStringAsFixed(1)} 小时',
            ),
            _buildStatRow(
              '计划时长',
              '${(totalPlannedMinutes / 60).toStringAsFixed(1)} 小时',
            ),
            _buildStatRow(
              '完成率',
              '${(completionRate * 100).toStringAsFixed(1)}%',
            ),
            _buildStatRow('总暂停次数', '$totalPauseCount 次'),
            _buildStatRow('总退出次数', '$totalExitCount 次'),
          ],
        ),
      ),
    );
  }

  Widget _buildSevenDaysChangeCard() {
    // 计算最近7天的数据
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final recentRecords = _records.where((record) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(
        record['startTime'],
      );
      return startTime.isAfter(sevenDaysAgo);
    }).toList();

    int recentSessions = recentRecords.length;
    int recentMinutes = recentRecords.fold(
      0,
      (sum, record) => (sum + record['actualDuration']) as int,
    );
    int recentPlannedMinutes = recentRecords.fold(
      0,
      (sum, record) => (sum + record['plannedDuration']) as int,
    );
    double recentCompletionRate = recentSessions > 0
        ? recentRecords
                  .where(
                    (record) =>
                        record['actualDuration'] >=
                        record['plannedDuration'] * 0.9,
                  )
                  .length /
              recentSessions
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '近7天变化',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStatRow('专注次数', '$recentSessions 次'),
            _buildStatRow(
              '专注时长',
              '${(recentMinutes / 60).toStringAsFixed(1)} 小时',
            ),
            _buildStatRow(
              '计划时长',
              '${(recentPlannedMinutes / 60).toStringAsFixed(1)} 小时',
            ),
            _buildStatRow(
              '完成率',
              '${(recentCompletionRate * 100).toStringAsFixed(1)}%',
            ),
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
    final todoTitle = record['todoTitle'];
    final todoProgress = record['todoProgress'];
    final todoFocusedTime = record['todoFocusedTime'];

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
                  DateFormat('MM-dd HH:mm').format(startTime),
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
            if (todoFocusedTime != null)
              _buildRecordStatRow('专注时间', '$todoFocusedTime 分钟'),
            _buildRecordStatRow('暂停次数', '$pauseCount 次'),
            _buildRecordStatRow('退出次数', '$exitCount 次'),
            if (todoTitle != null) ...[
              const SizedBox(height: 4),
              Text('关联任务: $todoTitle', style: const TextStyle(fontSize: 14)),
            ],
            if (todoProgress != null)
              _buildRecordStatRow('任务进度', '$todoProgress/10'),
            const SizedBox(height: 4),
            Text(
              '结束于 ${DateFormat('MM-dd HH:mm').format(endTime)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
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
}
