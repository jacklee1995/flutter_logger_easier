import 'dart:convert';
import 'dart:async';
import '../core/log_level.dart';
import '../core/log_record.dart';
import '../utils/log_utils.dart';
import '../interfaces/base_printer.dart';

class JsonPrinter implements BasePrinter {
  final bool prettyPrint;
  final bool includeStackTrace;
  bool _isClosed = false;
  int _printedLogs = 0;

  JsonPrinter({
    this.prettyPrint = false,
    this.includeStackTrace = true,
  });

  @override
  String printf(LogRecord record) {
    final jsonString = _formatLogRecord(record);
    _printedLogs++;
    return jsonString;
  }

  String _formatLogRecord(LogRecord record) {
    final Map<String, dynamic> logMap = {
      'timestamp': LogUtils.getTimestamp(),
      'level': LogUtils.getLevelString(record.level),
      'message': record.message,
    };

    if (record.error != null) {
      logMap['error'] = record.error.toString();
    }

    if (includeStackTrace && record.stackTrace != null) {
      logMap['stackTrace'] = record.stackTrace.toString();
    }

    return prettyPrint
        ? const JsonEncoder.withIndent('  ').convert(logMap)
        : json.encode(logMap);
  }

  @override
  Future<void> init() async {
    // JSON打印器不需要特殊的初始化操作
  }

  @override
  Future<void> close() async {
    _isClosed = true;
  }

  @override
  String get name => 'JsonPrinter';

  @override
  Map<String, dynamic> get config => {
        'prettyPrint': prettyPrint,
        'includeStackTrace': includeStackTrace,
      };

  @override
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    // 由于属性是final的，不能直接更新它们
    // 在实际应用中，可能需要重新设计这个类以允许更新配置
  }

  @override
  bool get isClosed => _isClosed;

  @override
  List<String> get supportedLevels =>
      ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'FATAL'];

  @override
  void setColorSupport(bool enabled) {
    // JSON打印器不支持颜色
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
    return json.encode({
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
    });
  }

  @override
  String formatMessage(dynamic message) => json.encode(message);

  @override
  String getLevelColor(LogLevel level) {
    // JSON打印器不使用颜色
    return '';
  }

  @override
  String getLevelBgColor(LogLevel level) {
    // JSON打印器不使用颜色
    return '';
  }

  @override
  String getLevelFgColor(LogLevel level) {
    // JSON打印器不使用颜色
    return '';
  }
}
