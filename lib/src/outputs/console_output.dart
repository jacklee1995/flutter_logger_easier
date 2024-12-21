import 'dart:io';
import 'dart:async';
import '../core/log_level.dart';
import '../utils/ansi_color.dart';
import '../utils/log_utils.dart';
import '../interfaces/base_output.dart';

/// ConsoleOutput 类负责将日志输出到控制台，并实现 BaseOutput 接口
class ConsoleOutput implements BaseOutput {
  final bool _useColor;
  bool _isClosed = false;
  int _writtenLogs = 0;

  /// 构造函数
  ///
  /// [useColor] 参数决定是否在控制台输出中使用颜色
  ConsoleOutput({bool useColor = true})
      : _useColor = useColor && LogUtils.isAnsiColorSupported();

  @override
  Future<void> write(String log) async {
    if (_isClosed) {
      throw StateError('ConsoleOutput has been closed');
    }

    if (_useColor) {
      _writeColoredMessage(log);
    } else {
      _writeMessage(log);
    }
    _writtenLogs++;
  }

  /// 写入带颜色的消息到控制台
  void _writeColoredMessage(String message) {
    // 这里假设日志级别信息包含在消息中，你可能需要根据实际情况调整
    final level = _extractLogLevel(message);
    final color = _getLevelColor(level);
    final coloredMessage = AnsiColor.wrap(message, color);
    _writeMessage(coloredMessage);
  }

  /// 写入消息到控制台
  void _writeMessage(String message) {
    stdout.writeln(message);
  }

  /// 从消息中提取日志级别（这是一个示例方法，你可能需要根据实际日志格式调整）
  LogLevel _extractLogLevel(String message) {
    if (message.contains('[TRACE]')) return LogLevel.trace;
    if (message.contains('[DEBUG]')) return LogLevel.debug;
    if (message.contains('[INFO]')) return LogLevel.info;
    if (message.contains('[WARN]')) return LogLevel.warn;
    if (message.contains('[ERROR]')) return LogLevel.error;
    if (message.contains('[CRITICAL]')) return LogLevel.critical;
    return LogLevel.info; // 默认级别
  }

  /// 根据日志级别获取对应的颜色
  String _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return AnsiColor.white;
      case LogLevel.debug:
        return AnsiColor.cyan;
      case LogLevel.info:
        return AnsiColor.green;
      case LogLevel.warn:
        return AnsiColor.yellow;
      case LogLevel.error:
        return AnsiColor.red;
      case LogLevel.critical:
        return AnsiColor.magenta;
      default:
        return AnsiColor.white;
    }
  }

  @override
  Future<void> flush() async {
    stdout.flush();
  }

  @override
  Future<void> close() async {
    if (!_isClosed) {
      await flush();
      _isClosed = true;
    }
  }

  @override
  bool get isClosed => _isClosed;

  @override
  String get name => 'ConsoleOutput';

  @override
  Map<String, dynamic> get config => {
        'useColor': _useColor,
      };

  @override
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    // 控制台输出不支持动态配置更新
  }

  @override
  Future<bool> isReady() async {
    return !_isClosed;
  }

  @override
  Future<void> reopen() async {
    _isClosed = false;
  }

  @override
  Map<String, dynamic> getStats() {
    return {
      'writtenLogs': _writtenLogs,
    };
  }

  @override
  void resetStats() {
    _writtenLogs = 0;
  }
}
