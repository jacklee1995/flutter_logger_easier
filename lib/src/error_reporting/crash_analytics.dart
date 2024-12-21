import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../core/log_level.dart';
import '../core/logger_easier_base.dart';

class CrashAnalytics {
  final Logger _logger;
  final String _crashLogDir;
  final int _maxCrashLogs;

  CrashAnalytics(this._logger, {String? crashLogDir, int? maxCrashLogs})
      : _crashLogDir = crashLogDir ?? 'crash_logs',
        _maxCrashLogs = maxCrashLogs ?? 10;

  Future<void> initialize() async {
    // 确保崩溃日志目录存在
    final dir = Directory(_crashLogDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 设置全局错误处理
    // 相应的错误处理逻辑应该在应用程序的主入口点设置
  }

  Future<void> logCrash(dynamic error, StackTrace? stackTrace) async {
    final crashLog = _formatCrashLog(error, stackTrace);
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'crash_$timestamp.log';
    final file = File(path.join(_crashLogDir, fileName));

    await file.writeAsString(crashLog);
    _logger.log(
        LogLevel.critical, 'Application crashed. Log saved to ${file.path}');

    await _cleanupOldLogs();
  }

  String _formatCrashLog(dynamic error, StackTrace? stackTrace) {
    final buffer = StringBuffer();
    buffer.writeln('Crash occurred at: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Error: $error');
    if (stackTrace != null) {
      buffer.writeln('StackTrace:');
      buffer.writeln(stackTrace);
    }
    return buffer.toString();
  }

  Future<void> _cleanupOldLogs() async {
    final dir = Directory(_crashLogDir);
    final files = await dir.list().toList();
    files
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    if (files.length > _maxCrashLogs) {
      for (var i = _maxCrashLogs; i < files.length; i++) {
        await files[i].delete();
      }
    }
  }

  Future<List<String>> getRecentCrashLogs({int limit = 5}) async {
    final dir = Directory(_crashLogDir);
    final files = await dir.list().toList();
    files
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    final logs = <String>[];
    for (var i = 0; i < limit && i < files.length; i++) {
      if (files[i] is File) {
        logs.add(await (files[i] as File).readAsString());
      }
    }

    return logs;
  }

  Future<Map<String, dynamic>> analyzeError(
      dynamic error, StackTrace stackTrace) async {
    _logger.log(LogLevel.info, 'Analyzing error...');

    // 基本错误信息
    final analysis = <String, dynamic>{
      'errorType': error.runtimeType.toString(),
      'errorMessage': error.toString(),
      'stackTraceLength': stackTrace.toString().split('\n').length,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 分析堆栈跟踪
    final stackLines = stackTrace.toString().split('\n');
    if (stackLines.isNotEmpty) {
      analysis['topStackFrame'] = stackLines.first.trim();
    }

    // 统计堆栈中最常出现的文件
    final fileCounts = <String, int>{};
    for (var line in stackLines) {
      final fileMatch = RegExp(r'(\S+\.dart)').firstMatch(line);
      if (fileMatch != null) {
        final file = fileMatch.group(1)!;
        fileCounts[file] = (fileCounts[file] ?? 0) + 1;
      }
    }
    if (fileCounts.isNotEmpty) {
      final mostFrequentFile =
          fileCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      analysis['mostFrequentFile'] = mostFrequentFile;
    }

    // 检查是否是异步错误
    analysis['isAsyncError'] =
        stackTrace.toString().contains('asynchronous suspension');

    // 记录分析结果
    _logger.log(LogLevel.info, 'Error analysis completed', error: analysis);

    return analysis;
  }

  Future<void> analyzeCrashTrends() async {
    // 这里可以实现崩溃趋势分析逻辑
    // 例如，统计最常见的崩溃类型，崩溃频率等
    _logger.log(LogLevel.info, 'Analyzing crash trends...');
    // TODO: 实现崩溃趋势分析
  }

  Future<void> sendCrashReports() async {
    // 这里可以实现将崩溃报告发送到远程服务器的逻辑
    _logger.log(LogLevel.info, 'Sending crash reports...');
    // TODO: 实现发送崩溃报告到远程服务器
  }

  Future<void> close() async {
    // 执行任何必要的清理操作
    _logger.log(LogLevel.info, 'Closing CrashAnalytics...');
  }
}
