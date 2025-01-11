import 'dart:io' show File, FileSystemException;
import '../core/log_level.dart' show LogLevel;
import '../core/log_record.dart' show LogRecord;
import '../utils/log_utils.dart' show LogUtils;

/// 日志分析器，用于分析日志文件中的各种模式和统计信息
class LogAnalyzer {
  static final RegExp _logPattern = RegExp(
    r'^\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2} \d{6} \[(TRACE|DEBUG|INFO|WARN|ERROR|CRITICAL|FATAL)\]',
  );

  static final RegExp _errorPattern = RegExp(
    r'Error: (.*?)(?=\n|$)',
    multiLine: true,
  );

  /// 分析日志级别分布
  Future<Map<String, int>> analyzeLogLevels(String logFile) async {
    final Map<String, int> levelCounts = {};
    final file = File(logFile);

    if (!await file.exists()) {
      throw FileSystemException('Log file not found', logFile);
    }

    final lines = await file.readAsLines();
    for (final line in lines) {
      final match = _logPattern.firstMatch(line);
      if (match != null) {
        final level = match.group(1)!;
        levelCounts[level] = (levelCounts[level] ?? 0) + 1;
      }
    }

    return levelCounts;
  }

  /// 分析错误模式
  Future<Map<String, int>> analyzeErrorPatterns(String logFile) async {
    final Map<String, int> errorPatterns = {};
    final file = File(logFile);

    if (!await file.exists()) {
      throw FileSystemException('Log file not found', logFile);
    }

    final content = await file.readAsString();
    final matches = _errorPattern.allMatches(content);

    for (final match in matches) {
      final errorMessage = match.group(1)!;
      errorPatterns[errorMessage] = (errorPatterns[errorMessage] ?? 0) + 1;
    }

    return errorPatterns;
  }

  /// 分析日志时间分布
  Future<Map<String, int>> analyzeTimeDistribution(
    String logFile, {
    Duration interval = const Duration(hours: 1),
  }) async {
    final Map<String, int> timeDistribution = {};
    final file = File(logFile);

    if (!await file.exists()) {
      throw FileSystemException('Log file not found', logFile);
    }

    final lines = await file.readAsLines();
    for (final line in lines) {
      final timestamp = _extractTimestamp(line);
      if (timestamp != null) {
        final bucket = _getTimeBucket(timestamp, interval);
        timeDistribution[bucket] = (timeDistribution[bucket] ?? 0) + 1;
      }
    }

    return timeDistribution;
  }

  /// 从日志行提取时间戳
  DateTime? _extractTimestamp(String line) {
    try {
      final parts = line.split(' ');
      if (parts.length >= 2) {
        final dateStr = '${parts[0]} ${parts[1]}';
        return DateTime.parse(dateStr.replaceAll('/', '-'));
      }
    } catch (e) {
      // 忽略解析错误
    }
    return null;
  }

  /// 获取时间分布的桶
  String _getTimeBucket(DateTime timestamp, Duration interval) {
    final bucket = timestamp.subtract(Duration(
      minutes: timestamp.minute % interval.inMinutes,
      seconds: timestamp.second,
      milliseconds: timestamp.millisecond,
      microseconds: timestamp.microsecond,
    ));
    return bucket.toString();
  }
}
