import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_state_manager.dart';
import '../models/focus.dart';

class StatisticsTab extends StatefulWidget {
  final AppStateManager appStateManager;

  const StatisticsTab({super.key, required this.appStateManager});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  List<FocusSession> _records = [];
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
      _records
          .sort((a, b) => b.focusRecord.start.compareTo(a.focusRecord.start));
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
        title: const Text('统计'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
      (sum, session) => sum + session.focusRecord.durationFocus,
    );
    int totalPlannedMinutes = _records.fold(
      0,
      (sum, session) => sum + session.focusRecord.durationTarget,
    );

    // 使用新的完成状态字段
    int completedSessions = _records.where((session) {
      return session.focusRecord.isCompleted;
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
      final dayRecords = _records.where((session) {
        final startTime = session.focusRecord.start;
        return startTime.year == date.year &&
            startTime.month == date.month &&
            startTime.day == date.day;
      }).toList();

      // 计算当日专注时长
      int dailyMinutes = dayRecords.fold(
        0,
        (sum, session) => sum + session.focusRecord.durationFocus,
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

  Widget _buildRecordCard(FocusSession session) {
    final focusRecord = session.focusRecord;
    final startTime = focusRecord.start;
    final endTime = focusRecord.end;
    final plannedDuration = focusRecord.durationTarget;
    final actualDuration = focusRecord.durationFocus;
    final interruptedDuration = focusRecord.durationInterrupted;
    final focusTodos = session.focusTodos;

    // 使用新的完成状态字段
    bool isCompleted = focusRecord.isCompleted;

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
                      onPressed: () => _showDeleteConfirmDialog(session),
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
                  child: _buildRecordStatRow('中断', '$interruptedDuration 分钟'),
                ),
                Expanded(
                  child: _buildRecordStatRow('完成率',
                      '${focusRecord.completionRate.toStringAsFixed(1)}%'),
                ),
              ],
            ),
            if (focusTodos.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text(
                '关联任务:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (var focusTodo in focusTodos)
                _buildFocusTodoInfoRow(focusTodo),
            ],
          ],
        ),
      ),
    );
  }

  // 添加删除确认对话框
  void _showDeleteConfirmDialog(FocusSession session) {
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
              _deleteRecord(session);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 添加删除记录方法
  Future<void> _deleteRecord(FocusSession session) async {
    try {
      await widget.appStateManager.deleteFocusRecord(session.focusRecord.id);
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

  Widget _buildFocusTodoInfoRow(FocusTodo focusTodo) {
    final todoId = focusTodo.todoId;
    final todoTitle = focusTodo.todoTitle;
    final todoCategory = focusTodo.todoCategory;
    final duration = focusTodo.duration;
    final progressImprovement = focusTodo.progressImprovement;

    // 构建任务显示文本
    String taskDisplay;
    if (todoTitle != null && todoTitle.isNotEmpty) {
      taskDisplay = todoTitle;
      if (todoCategory != null && todoCategory.isNotEmpty) {
        taskDisplay += ' ($todoCategory)';
      }
    } else {
      taskDisplay =
          todoId.isNotEmpty ? '任务ID: ${todoId.substring(0, 8)}...' : '未知任务';
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              taskDisplay,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (progressImprovement > 0)
            Text(
              '进度提升: +$progressImprovement',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          if (duration > 0) ...[
            const SizedBox(width: 8),
            Text(
              '专注: $duration分钟',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ],
      ),
    );
  }
}
