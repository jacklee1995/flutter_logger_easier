import 'dart:async';
import '../core/log_record.dart';
import '../core/log_level.dart';
import '../utils/ansi_color.dart';
import '../utils/log_utils.dart';
import '../interfaces/base_printer.dart';
import 'dart:io' show stdout;

/// 控制台日志打印器，提供灵活的日志输出和格式化功能
///
/// 支持颜色、自定义输出、行长度控制等特性
class ConsolePrinter implements BasePrinter {
  /// 是否启用颜色输出
  bool useColor;

  /// 最大行长度限制
  int? maxLineLength;

  /// 打印器关闭状态
  bool _isClosed = false;

  /// 已打印日志数量
  int _printedLogs = 0;

  /// 自定义输出函数，如果未提供则使用默认的 stdout.writeln
  final void Function(String)? _outputFunction;

  /// 构造函数
  ///
  /// [useColor] 是否启用颜色输出，默认为 true
  /// [maxLineLength] 最大行长度限制
  /// [outputFunction] 自定义输出函数
  ConsolePrinter({
    this.useColor = true,
    this.maxLineLength,
    void Function(String)? outputFunction,
  }) : _outputFunction = outputFunction;

  @override
  String printf(LogRecord record) {
    final message = _formatLogRecord(record);
    _outputToConsole(message);
    _printedLogs++;
    return message;
  }

  /// 输出消息到控制台
  ///
  /// 优先使用自定义输出函数，否则使用标准输出
  void _outputToConsole(String message) {
    if (_outputFunction != null) {
      _outputFunction(message);
    } else {
      stdout.writeln(message);
    }
  }

  @override
  Future<void> init() async {
    // 控制台打印器不需要特殊的初始化操作
  }

  @override
  Future<void> close() async {
    _isClosed = true;
  }

  @override
  String get name => 'ConsolePrinter';

  @override
  Map<String, dynamic> get config => {
        'useColor': useColor,
        'maxLineLength': maxLineLength,
      };

  @override
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    if (newConfig.containsKey('useColor')) {
      useColor = newConfig['useColor'] as bool;
    }
    if (newConfig.containsKey('maxLineLength')) {
      maxLineLength = newConfig['maxLineLength'] as int?;
    }
  }

  @override
  bool get isClosed => _isClosed;

  @override
  List<String> get supportedLevels =>
      ['TRACE', 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICLE', 'FATAL'];

  @override
  void setColorSupport(bool enabled) {
    useColor = enabled;
  }

  @override
  Map<String, dynamic> getStats() {
    return {
      'printedLogs': _printedLogs,
    };
  }

  @override
  void resetStats() {
    _printedLogs = 0;
  }

  @override
  String formatError(dynamic error, StackTrace? stackTrace) {
    // 如果没有堆栈信息，直接返回错误信息
    if (stackTrace == null) {
      return 'Error: $error';
    }

    String errorStr =
        '══╡ Traceback (most recent call last) ╞═══════════════════════════════════════════════════════════\n';
    errorStr += error.toString().replaceFirst('Error: ', '');
    errorStr += '\n${stackTrace.toString().trim()}';
    errorStr +=
        '════════════════════════════════════════════════════════════════════════════════════════════════════';
    // 直接拼接错误信息和堆栈跟踪
    return errorStr;
  }

  @override
  String formatMessage(dynamic message) => message.toString();

  @override
  String getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return AnsiColor.cyan;
      case LogLevel.debug:
        return AnsiColor.blue;
      case LogLevel.info:
        return AnsiColor.green;
      case LogLevel.warn:
        return AnsiColor.yellow;
      case LogLevel.error:
        return AnsiColor.brightRed;
      case LogLevel.critical:
        return AnsiColor.pink;
      case LogLevel.fatal:
        return AnsiColor.magenta;
    }
  }

  @override
  String getLevelFgColor(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return AnsiColor.white;
      case LogLevel.debug:
        return AnsiColor.white;
      case LogLevel.info:
        return AnsiColor.black;
      case LogLevel.warn:
        return AnsiColor.black;
      case LogLevel.error:
        return AnsiColor.white;
      case LogLevel.critical:
        return AnsiColor.white;
      case LogLevel.fatal:
        return AnsiColor.white;
    }
  }

  @override
  String getLevelBgColor(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return AnsiColor.bgCyan;
      case LogLevel.debug:
        return AnsiColor.bgBlue;
      case LogLevel.info:
        return AnsiColor.bgGreen;
      case LogLevel.warn:
        return AnsiColor.bgYellow;
      case LogLevel.error:
        return AnsiColor.bgRed;
      case LogLevel.critical:
        return AnsiColor.bgMagenta;
      case LogLevel.fatal:
        return AnsiColor.bgBrightRed;
    }
  }

  /// 格式化日志记录
  ///
  /// 根据配置生成格式化的日志消息
  String _formatLogRecord(LogRecord record) {
    final levelString = LogUtils.getLevelString(record.level);
    final timestamp = LogUtils.getTimestamp();
    final color = getLevelColor(record.level);
    final fgColor = getLevelFgColor(record.level);
    final bgColor = getLevelBgColor(record.level);

    if (!useColor) {
      // 非颜色模式的日志格式
      String msg =
          '[$levelString] [$timestamp] - ${formatMessage(record.message)}';

      // 错误信息处理
      if (record.error != null) {
        String errorMessage = formatError(record.error, record.stackTrace);
        msg += '\n$errorMessage';
      }

      // 行长度限制
      if (maxLineLength != null) {
        msg = _wrapLines(msg, maxLineLength!);
      }

      return msg;
    }

    // 颜色模式的日志格式（之前的代码保持不变）
    String msg =
        AnsiColor.wrapWithBackground('[$levelString]', fgColor, bgColor);

    msg += AnsiColor.wrap(
      ' [$timestamp] - ${formatMessage(record.message)}',
      color,
    );

    // 错误信息处理
    if (record.error != null) {
      String errorMessage = formatError(record.error, record.stackTrace);
      errorMessage = AnsiColor.wrapMultiline(errorMessage, AnsiColor.dim);
      msg += '\n$errorMessage';
    }

    // 行长度限制
    if (maxLineLength != null) {
      msg = _wrapLines(msg, maxLineLength!);
    }

    return msg;
  }

  /// 按指定长度换行
  String _wrapLines(String text, int lineLength) {
    final lines = text.split('\n');
    return lines.map((line) {
      if (line.length <= lineLength) return line;
      final wrappedLines = <String>[];
      for (var i = 0; i < line.length; i += lineLength) {
        wrappedLines.add(line.substring(
            i, i + lineLength > line.length ? line.length : i + lineLength));
      }
      return wrappedLines.join('\n');
    }).join('\n');
  }
}
