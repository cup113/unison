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

    // 使用新的完成状态字段，对于旧记录使用兼容逻辑
    int completedSessions = _records.where((record) {
      // 如果有 isCompleted 字段，直接使用它
      if (record.containsKey('isCompleted')) {
        return record['isCompleted'] == true;
      }
      // 对于旧记录，使用原来的逻辑
      return record['actualDuration'] >= record['plannedDuration'];
    }).length;

    double completionRate =
        totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0;

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
    // 计算最近7天的数据
    final now = DateTime.now();
    List<Map<String, dynamic>> dailyData = [];

    // 初始化最近7天的数据（包括今天）
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('MM-dd').format(date);

      // 查找该日期的记录
      final dayRecords = _records.where((record) {
        final startTime =
            DateTime.fromMillisecondsSinceEpoch(record['startTime']);
        return startTime.year == date.year &&
            startTime.month == date.month &&
            startTime.day == date.day;
      }).toList();

      // 计算当日专注时长
      int dailyMinutes = dayRecords.fold(
        0,
        (sum, record) => (sum + record['actualDuration']) as int,
      );

      dailyData.add({
        'date': dateStr,
        'minutes': dailyMinutes,
        'records': dayRecords,
      });
    }

    // 计算最大专注时长用于图表比例
    int maxMinutes = dailyData
        .map((d) => d['minutes'] as int)
        .reduce((a, b) => a > b ? a : b);
    if (maxMinutes == 0) maxMinutes = 1; // 避免除零

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
            // 显示每日专注时长的柱状图
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var dayData in dailyData)
                    _buildDayChartBar(
                      dayData['date'],
                      dayData['minutes'],
                      maxMinutes,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // 显示统计数据摘要
            _buildStatRow(
              '平均每日专注',
              '${(dailyData.fold(0, (prev, elem) => prev + (elem['minutes'] as int)) / 7).toStringAsFixed(1)} 分钟',
            ),
            _buildStatRow(
              '最专注的一天',
              '$maxMinutes 分钟',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChartBar(String date, int minutes, int maxMinutes) {
    double barHeight = maxMinutes > 0 ? (minutes / maxMinutes) * 100 : 0;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 数值标签
          Text(
            minutes.toString(),
            style: const TextStyle(fontSize: 10),
          ),
          // 图表柱
          Container(
            height: barHeight,
            width: 20,
            decoration: BoxDecoration(
              color: minutes > 0 ? Colors.blue : Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ),
          // 日期标签
          Text(
            date,
            style: const TextStyle(fontSize: 10),
          ),
        ],
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
    final todoData = record['todoData'];

    // 使用新的完成状态字段，对于旧记录使用兼容逻辑
    bool isCompleted;
    if (record.containsKey('isCompleted')) {
      // 新记录直接使用 isCompleted 字段
      isCompleted = record['isCompleted'] == true;
    } else {
      // 旧记录使用原来的逻辑
      isCompleted = actualDuration >= plannedDuration;
    }

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
                Expanded(
                  // 添加 Expanded 防止溢出
                  child: Text(
                    '${DateFormat('MM-dd HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  // 用 Row 包裹状态和删除按钮
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      // 添加删除按钮
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
                      onPressed: () => _showDeleteConfirmDialog(record),
                      tooltip: '删除记录',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildRecordStatRow('计划', '$plannedDuration 分钟'),
                ),
                Expanded(
                  child: _buildRecordStatRow('实际', '$actualDuration 分钟'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildRecordStatRow('暂停', '$pauseCount 次'),
                ),
                Expanded(
                  child: _buildRecordStatRow('退出', '$exitCount 次'),
                ),
              ],
            ),
            if (todoData != null) ...[
              const SizedBox(height: 4),
              const Text(
                '关联任务:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (todoData is List)
                for (var todo in todoData) _buildTodoInfoRow(todo)
              else if (todoData is Map)
                _buildTodoInfoRow(Map<String, dynamic>.from(todoData)),
            ],
          ],
        ),
      ),
    );
  }

  // 添加删除确认对话框
  void _showDeleteConfirmDialog(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条专注记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecord(record);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 添加删除记录方法
  Future<void> _deleteRecord(Map<String, dynamic> record) async {
    try {
      await widget.appStateManager.deleteFocusRecord(record['id']);
      await _loadRecords(); // 重新加载数据
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录已删除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除失败，请重试')),
        );
      }
    }
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
