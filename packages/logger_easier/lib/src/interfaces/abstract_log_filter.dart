import '../core/log_record.dart' show LogRecord;

/// 日志过滤器的抽象基类
///
/// 所有具体的日志过滤器实现都应该实现这个接口
abstract class AbstractLogFilter {
  /// 判断是否应该记录给定的日志记录
  ///
  /// [record] 是要判断的日志记录
  /// 返回 true 如果应该记录该日志，否则返回 false
  bool shouldLog(LogRecord record);
}
