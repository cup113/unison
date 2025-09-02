import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? stackTrace;
  final Map<String, dynamic>? context;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.stackTrace,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level.name,
        'message': message,
        if (stackTrace != null) 'stackTrace': stackTrace,
        if (context != null && context!.isNotEmpty) 'context': context,
      };

  @override
  String toString() {
    return '${timestamp.toIso8601String()} [${level.name.toUpperCase()}] $message'
        '${stackTrace != null ? '\nStack: $stackTrace' : ''}'
        '${context != null ? '\nContext: ${jsonEncode(context)}' : ''}';
  }
}

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  final List<LogEntry> _inMemoryLogs = [];
  static const int _maxInMemoryLogs = 1000;
  static const int _logFileMaxSize = 10 * 1024 * 1024; // 10MB
  static const int _maxLogFiles = 7; // 保留7天日志

  File? _currentLogFile;
  Directory? _logDirectory;
  StreamController<LogEntry>? _logStreamController;

  Future<void> initialize() async {
    try {
      _logDirectory = await getApplicationDocumentsDirectory();
      _logDirectory = Directory('${_logDirectory!.path}/logs');
      if (!await _logDirectory!.exists()) {
        await _logDirectory!.create(recursive: true);
      }

      // 启动时记录系统信息
      await _logSystemInfo();
      
      _logStreamController = StreamController<LogEntry>.broadcast();
    } catch (e) {
      // 即使初始化失败也要能记录日志
      debugPrint('Logging service initialization failed: $e');
    }
  }

  Future<void> _logSystemInfo() async {
    final systemInfo = {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'appVersion': '1.0.0', // TODO: 从pubspec.yaml获取
      'startTime': DateTime.now().toIso8601String(),
    };

    log(
      level: LogLevel.info,
      message: 'Application started',
      context: systemInfo,
    );
  }

  Future<File> _getCurrentLogFile() async {
    if (_currentLogFile != null) {
      final length = await _currentLogFile!.length();
      if (length < _logFileMaxSize) {
        return _currentLogFile!;
      }
    }

    // 创建新的日志文件
    final now = DateTime.now();
    final fileName = 'app-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.log';
    _currentLogFile = File('${_logDirectory!.path}/$fileName');
    
    // 清理旧日志文件
    await _cleanupOldLogs();
    
    return _currentLogFile!;
  }

  Future<void> _cleanupOldLogs() async {
    try {
      final files = await _logDirectory!.list().toList();
      final logFiles = files.whereType<File>().where((file) => file.path.endsWith('.log')).toList();
      
      if (logFiles.length > _maxLogFiles) {
        // 按修改时间排序，删除最旧的
        logFiles.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
        for (int i = 0; i < logFiles.length - _maxLogFiles; i++) {
          await logFiles[i].delete();
        }
      }
    } catch (e) {
      debugPrint('Failed to cleanup old logs: $e');
    }
  }

  Future<void> log({
    required LogLevel level,
    required String message,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      stackTrace: stackTrace?.toString(),
      context: context,
    );

    // 内存中缓存
    _inMemoryLogs.add(entry);
    if (_inMemoryLogs.length > _maxInMemoryLogs) {
      _inMemoryLogs.removeAt(0);
    }

    // 输出到控制台（开发时）
    if (kDebugMode) {
      debugPrint(entry.toString());
    }

    // 写入文件
    try {
      if (_logDirectory != null) {
        final logFile = await _getCurrentLogFile();
        final logLine = '${jsonEncode(entry.toJson())}\n';
        await logFile.writeAsString(logLine, mode: FileMode.append);
      }
    } catch (e) {
      debugPrint('Failed to write log to file: $e');
    }

    // 通知监听器
    _logStreamController?.add(entry);
  }

  // 便捷方法
  Future<void> debug(String message, {Map<String, dynamic>? context}) =>
      log(level: LogLevel.debug, message: message, context: context);

  Future<void> info(String message, {Map<String, dynamic>? context}) =>
      log(level: LogLevel.info, message: message, context: context);

  Future<void> warning(String message, {StackTrace? stackTrace, Map<String, dynamic>? context}) =>
      log(level: LogLevel.warning, message: message, stackTrace: stackTrace, context: context);

  Future<void> error(String message, {StackTrace? stackTrace, Map<String, dynamic>? context}) =>
      log(level: LogLevel.error, message: message, stackTrace: stackTrace, context: context);

  Future<void> critical(String message, {StackTrace? stackTrace, Map<String, dynamic>? context}) =>
      log(level: LogLevel.critical, message: message, stackTrace: stackTrace, context: context);

  // 读取日志
  Future<List<LogEntry>> getLogs({int limit = 100, int offset = 0}) async {
    if (_logDirectory == null) return _inMemoryLogs;

    try {
      final logFile = await _getCurrentLogFile();
      if (!await logFile.exists()) return [];

      final content = await logFile.readAsString();
      final lines = content.split('\n').where((line) => line.isNotEmpty).toList();
      
      final logs = lines.reversed.skip(offset).take(limit).map((line) {
        try {
          final json = jsonDecode(line);
          return LogEntry(
            timestamp: DateTime.parse(json['timestamp']),
            level: LogLevel.values.firstWhere((l) => l.name == json['level']),
            message: json['message'],
            stackTrace: json['stackTrace'],
            context: json['context'] != null ? Map<String, dynamic>.from(json['context']) : null,
          );
        } catch (e) {
          return null;
        }
      }).whereType<LogEntry>().toList();

      return logs;
    } catch (e) {
      return _inMemoryLogs.reversed.skip(offset).take(limit).toList();
    }
  }

  Stream<LogEntry> get onLog => _logStreamController?.stream ?? const Stream.empty();

  Future<void> dispose() async {
    await _logStreamController?.close();
    _logStreamController = null;
  }
}