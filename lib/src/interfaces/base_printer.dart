import 'dart:async';
import '../core/log_level.dart';
import '../core/log_record.dart';

/// 日志打印器的抽象基类
///
/// 所有具体的日志打印器实现都应该继承自这个类
abstract class BasePrinter {
  /// 打印日志
  ///
  /// [record] 是要打印的日志记录
  /// 返回打印后的字符串
  String printf(LogRecord record);

  /// 初始化打印器
  ///
  /// 在开始使用打印器之前调用此方法进行任何必要的设置
  /// 返回一个 [Future] 表示初始化操作的完成
  Future<void> init() async {}

  /// 关闭打印器
  ///
  /// 清理资源并执行任何必要的关闭操作
  /// 返回一个 [Future] 表示关闭操作的完成
  Future<void> close() async {}

  /// 获取打印器的名称
  String get name;

  /// 获取打印器的配置信息
  Map<String, dynamic> get config;

  /// 更新打印器的配置
  ///
  /// [newConfig] 是新的配置信息
  /// 返回一个 [Future] 表示配置更新操作的完成
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {}

  /// 检查打印器是否已关闭
  bool get isClosed => false;

  /// 获取打印器支持的日志级别
  List<String> get supportedLevels =>
      ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICLE', 'FATAL'];

  /// 设置打印器的颜色支持
  ///
  /// [enabled] 表示是否启用颜色支持
  void setColorSupport(bool enabled) {}

  /// 获取打印器的统计信息
  ///
  /// 返回一个包含统计信息的 [Map]
  Map<String, dynamic> getStats() => {};

  /// 重置打印器的统计信息
  void resetStats() {}

  /// 格式化异常信息
  ///
  /// [error] 是异常对象
  /// [stackTrace] 是堆栈跟踪信息
  /// 返回格式化后的异常信息字符串
  String formatError(dynamic error, StackTrace? stackTrace) {
    return 'Error: $error\nStackTrace: $stackTrace';
  }

  /// 格式化日志消息
  ///
  /// [message] 是日志消息
  /// 返回格式化后的日志消息字符串
  String formatMessage(dynamic message) => message.toString();

  /// 获取日志级别对应的颜色代码
  ///
  /// [level] 是日志级别
  /// 返回对应的颜色代码字符串
  String getLevelColor(LogLevel level) => '';

  String getLevelFgColor(LogLevel level) => '';

  String getLevelBgColor(LogLevel level) => '';
}
