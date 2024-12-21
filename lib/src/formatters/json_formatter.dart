import 'dart:convert';
import '../core/log_record.dart';
import '../interfaces/log_formatter.dart';

/// JSON格式的日志格式化器
class JsonFormatter implements LogFormatter {
  /// 是否美化输出的JSON
  final bool prettyPrint;

  /// 构造函数
  ///
  /// [prettyPrint] 如果为true,则输出格式化后的JSON,默认为false
  JsonFormatter({this.prettyPrint = false});

  @override
  String format(LogRecord record) {
    final Map<String, dynamic> logMap = {
      'timestamp': record.timestamp.toIso8601String(),
      'level': record.level.toString(),
      'message': record.message,
    };

    if (record.error != null) {
      logMap['error'] = record.error.toString();
    }

    if (record.stackTrace != null) {
      logMap['stackTrace'] = record.stackTrace.toString();
    }

    // 移除了不存在的属性

    return prettyPrint
        ? const JsonEncoder.withIndent('  ').convert(logMap)
        : json.encode(logMap);
  }

  @override
  String get name => 'JsonFormatter';

  @override
  Map<String, dynamic> get config => {'prettyPrint': prettyPrint};

  @override
  void updateConfig(Map<String, dynamic> newConfig) {
    // 这里我们只能更新 prettyPrint，因为它是 final 的，所以实际上不能更新
    // 在实际应用中，您可能需要重新设计这个类以允许更新配置
  }

  @override
  LogFormatter clone() => JsonFormatter(prettyPrint: prettyPrint);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonFormatter &&
          runtimeType == other.runtimeType &&
          prettyPrint == other.prettyPrint;

  @override
  int get hashCode => prettyPrint.hashCode;

  @override
  String toString() => 'JsonFormatter(prettyPrint: $prettyPrint)';

  @override
  List<String> get supportedPlaceholders =>
      ['timestamp', 'level', 'message', 'error', 'stackTrace'];

  @override
  bool isValidFormatString(String formatString) {
    // JSON 格式化器不使用格式字符串，所以总是返回 true
    return true;
  }
}
