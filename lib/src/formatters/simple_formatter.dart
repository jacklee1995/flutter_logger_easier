import '../core/log_record.dart';
import '../utils/log_utils.dart';
import '../interfaces/log_formatter.dart';

/// 简单的日志格式化器
class SimpleFormatter implements LogFormatter {
  final bool includeTimestamp;
  final bool includeLevel;
  final bool includeStackTrace;

  /// 构造函数
  ///
  /// [includeTimestamp] - 是否包含时间戳
  /// [includeLevel] - 是否包含日志级别
  /// [includeStackTrace] - 是否包含堆栈跟踪
  SimpleFormatter({
    this.includeTimestamp = true,
    this.includeLevel = true,
    this.includeStackTrace = false,
  });

  @override
  String format(LogRecord record) {
    final buffer = StringBuffer();

    if (includeTimestamp) {
      buffer.write('[${record.timestamp}] ');
    }

    if (includeLevel) {
      buffer.write('${LogUtils.getLevelString(record.level)} ');
    }

    buffer.write(record.message);

    if (record.error != null) {
      buffer.write('\nError: ${record.error}');
    }

    if (includeStackTrace && record.stackTrace != null) {
      buffer.write('\nStack Trace:\n${record.stackTrace}');
    }

    return buffer.toString();
  }

  @override
  String get name => 'SimpleFormatter';

  @override
  Map<String, dynamic> get config => {
        'includeTimestamp': includeTimestamp,
        'includeLevel': includeLevel,
        'includeStackTrace': includeStackTrace,
      };

  @override
  void updateConfig(Map<String, dynamic> newConfig) {
    // 注意：由于字段是final的，我们不能真正地更新配置
    // 在实际应用中，您可能需要重新设计这个类以允许更新配置
  }

  @override
  LogFormatter clone() => SimpleFormatter(
        includeTimestamp: includeTimestamp,
        includeLevel: includeLevel,
        includeStackTrace: includeStackTrace,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleFormatter &&
          runtimeType == other.runtimeType &&
          includeTimestamp == other.includeTimestamp &&
          includeLevel == other.includeLevel &&
          includeStackTrace == other.includeStackTrace;

  @override
  int get hashCode =>
      Object.hash(includeTimestamp, includeLevel, includeStackTrace);

  @override
  String toString() => 'SimpleFormatter(includeTimestamp: $includeTimestamp, '
      'includeLevel: $includeLevel, includeStackTrace: $includeStackTrace)';

  @override
  List<String> get supportedPlaceholders =>
      ['timestamp', 'level', 'message', 'error', 'stackTrace'];

  @override
  bool isValidFormatString(String formatString) {
    // 简单格式化器不使用格式字符串，所以总是返回 true
    return true;
  }
}
