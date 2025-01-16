import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:stack_trace/stack_trace.dart';
import '../core/log_level.dart';
import '../core/log_record.dart';

/// 日志工具类，提供一些通用的日志相关功能
class LogUtils {
  /// 获取当前时间戳
  static String getTimestamp() {
    return DateFormat('yyyy/MM/dd HH:mm:ss SSSSSS').format(DateTime.now());
  }

  /// 获取调用栈信息
  static String getStackTrace() {
    final trace = Trace.current();
    return trace.frames
        .skip(3)
        .take(5)
        .map((frame) => frame.toString())
        .join('\n');
  }

  /// 将 LogRecord 转换为 JSON 字符串
  static String logRecordToJson(LogRecord record) {
    return jsonEncode({
      'timestamp': record.timestamp,
      'level': record.level.toString(),
      'message': record.message,
      'error': record.error?.toString(),
      'stackTrace': record.stackTrace,
    });
  }

  /// 从 JSON 字符串解析 LogRecord
  static LogRecord logRecordFromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return LogRecord(
      LogLevel.values.firstWhere((e) => e.toString() == json['level']),
      json['message'],
      timestamp: json['timestamp'],
      error: json['error'],
      stackTrace: json['stackTrace'],
    );
  }

  /// 截断长消息
  static String truncateMessage(String message, int maxLength) {
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength)}...';
  }

  /// 格式化异常信息
  static String formatException(dynamic error, StackTrace? stackTrace) {
    final buffer = StringBuffer();
    buffer.writeln('Error: $error');
    if (stackTrace != null) {
      buffer.writeln('StackTrace:');
      buffer.writeln(Trace.from(stackTrace).terse);
    }
    return buffer.toString();
  }

  /// 获取日志级别对应的字符串表示
  static String getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return 'TRACE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.critical:
        return 'CRITICAL';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  /// 检查是否启用了ANSI颜色支持
  static bool isAnsiColorSupported() {
    // 优先检查环境变量
    final term = Platform.environment['TERM'];
    final colorTerm = Platform.environment['COLORTERM'];

    // 明确的颜色终端环境变量
    if (colorTerm != null) {
      return colorTerm.contains('256color') ||
          colorTerm.contains('24bit') ||
          colorTerm.contains('truecolor');
    }

    // 检查常见的支持颜色的终端类型
    if (term != null) {
      return term.contains('xterm') ||
          term.contains('screen') ||
          term.contains('linux') ||
          term.contains('vt100') ||
          term.contains('256color');
    }

    // 最后回退到 stdout 的检查
    return stdout.supportsAnsiEscapes;
  }
}
