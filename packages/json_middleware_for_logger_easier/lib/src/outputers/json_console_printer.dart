import 'dart:convert';

import 'package:logger_easier/logger_easier.dart';

class JsonConsolePrinter extends AbstractOutputer {
  /// 是否启用颜色输出
  bool useColor;
  final OutputFunction? outputFunction;
  final JsonEncoder _encoder = JsonEncoder.withIndent('  ');
  bool _isClosed = false;

  JsonConsolePrinter({
    this.useColor = true,
    this.outputFunction,
  });

  String _formatLogRecord(LogRecord record) {
    final levelString = LogUtils.getLevelString(record.level);
    final timestamp = LogUtils.getTimestamp();

    // 如果不使用颜色，直接返回未着色的 JSON

    if (!useColor) {
      return _encoder.convert({
        'datatime': timestamp,
        'level': levelString,
        'message': record.message,
        if (record.error != null) 'error': record.error.toString(),
        if (record.stackTrace != null)
          'stackTrace': record.stackTrace.toString(),
      });
    }

    // 获取颜色
    final color = getLevelColor(record.level);
    final fgColor = getLevelFgColor(record.level);
    final bgColor = getLevelBgColor(record.level);

    // 对级别使用背景色和前景色
    final coloredLevel = AnsiColor.wrapWithBackground(
      levelString,
      fgColor,
      bgColor,
    );

    // 对错误信息使用暗色
    final coloredError = record.error != null
        ? AnsiColor.wrapMultiline(
            record.error.toString(),
            AnsiColor.dim,
          )
        : null;

    // 返回带颜色的 JSON
    return AnsiColor.wrap(
        _encoder.convert({
          'datatime': timestamp,
          'level': coloredLevel,
          'message': record.message,
          if (coloredError != null) 'error': coloredError,
          if (record.stackTrace != null)
            'stackTrace': record.stackTrace.toString(),
        }),
        color);
  }

  @override
  String printf(LogRecord record) {
    if (_isClosed) {
      throw StateError('Cannot write to a closed printer');
    }

    // 格式化日志记录为 JSON
    String output = _formatLogRecord(record);

    // 输出 JSON 格式的日志
    if (outputFunction != null) {
      outputFunction!(output);
    } else {
      print(output);
    }

    return output;
  }

  @override
  String get name => 'JsonConsolePrinter';

  @override
  Map<String, dynamic> get config => {
        'outputFunction': outputFunction != null ? 'custom' : 'default',
      };

  @override
  bool get isClosed => _isClosed;

  @override
  Future<void> close() async {
    _isClosed = true;
  }

  @override
  void setColorSupport(bool enabled) {
    useColor = enabled;
  }

  @override
  String formatMessage(dynamic message) => message.toString();

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
}
