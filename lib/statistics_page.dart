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

// ... existing code ...
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
            // 第一行：时长信息
            Row(
              children: [
                _buildCompactRecordStat(
                    '计划', '$plannedDuration分钟', Colors.blue),
                const SizedBox(width: 8),
                _buildCompactRecordStat(
                    '实际',
                    '$actualDuration分钟',
                    actualDuration >= plannedDuration
                        ? Colors.green
                        : Colors.red),
                if (todoFocusedTime != null) ...[
                  const SizedBox(width: 8),
                  _buildCompactRecordStat(
                      '专注', '${todoFocusedTime}分钟', Colors.purple),
                ],
              ],
            ),
            const SizedBox(height: 4),
            // 第二行：次数信息和任务信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildCompactRecordStat(
                        '暂停', '$pauseCount次', Colors.orange),
                    const SizedBox(width: 8),
                    _buildCompactRecordStat('退出', '$exitCount次', Colors.orange),
                  ],
                ),
                if (todoTitle != null)
                  Expanded(
                    child: Text(
                      todoTitle,
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),
            if (todoProgress != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(
                  value: (todoProgress ?? 0) / 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactRecordStat(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }
}
