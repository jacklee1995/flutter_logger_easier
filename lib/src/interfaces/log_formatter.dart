import '../core/log_record.dart';

/// 日志格式化器接口
///
/// 所有具体的日志格式化实现都应该实现这个接口
abstract class LogFormatter {
  /// 格式化日志记录
  ///
  /// [record] 是要格式化的日志记录
  /// 返回格式化后的日志字符串
  String format(LogRecord record);

  /// 获取格式化器的名称
  String get name;

  /// 获取格式化器的配置
  Map<String, dynamic> get config;

  /// 更新格式化器的配置
  ///
  /// [newConfig] 是新的配置信息
  void updateConfig(Map<String, dynamic> newConfig);

  /// 创建一个新的格式化器实例，但保持相同的配置
  LogFormatter clone();

  /// 检查两个格式化器是否相等
  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  /// 返回格式化器的字符串表示
  @override
  String toString();

  /// 获取格式化器支持的占位符列表
  List<String> get supportedPlaceholders;

  /// 检查给定的格式字符串是否有效
  ///
  /// [formatString] 是要检查的格式字符串
  /// 返回 true 如果格式字符串有效，否则返回 false
  bool isValidFormatString(String formatString);

  /// 从给定的格式字符串创建一个新的格式化器
  ///
  /// [formatString] 是用于创建格式化器的格式字符串
  /// 返回一个新的 LogFormatter 实例
  factory LogFormatter.fromFormatString(String formatString) {
    // 这里应该根据格式字符串创建适当的格式化器
    // 实际实现可能会更复杂，可能需要解析格式字符串并创建相应的格式化器
    throw UnimplementedError('This factory method should be implemented in a concrete class');
  }
}

/// 简单的日志格式化器实现
class SimpleLogFormatter implements LogFormatter {
  @override
  String format(LogRecord record) {
    return '${record.timestamp} [${record.level}] ${record.message}';
  }

  @override
  String get name => 'SimpleLogFormatter';

  @override
  Map<String, dynamic> get config => {};

  @override
  void updateConfig(Map<String, dynamic> newConfig) {
    // 这个简单实现不需要配置，所以这个方法是空的
  }

  @override
  LogFormatter clone() => SimpleLogFormatter();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleLogFormatter && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'SimpleLogFormatter()';

  @override
  List<String> get supportedPlaceholders => ['timestamp', 'level', 'message'];

  @override
  bool isValidFormatString(String formatString) {
    // 这个简单实现总是返回true
    return true;
  }
}