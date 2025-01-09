import '../../core/log_record.dart' show LogRecord;
import '../../interfaces/abstract_log_filter.dart' show AbstractLogFilter;

/// 复合过滤器
///
/// 组合多个过滤器，只有当所有过滤器都返回 true 时才记录日志
class CompositeFilter implements AbstractLogFilter {
  final List<AbstractLogFilter> filters;

  /// 构造函数
  ///
  /// [filters] 是要组合的过滤器列表
  CompositeFilter(this.filters);

  @override
  bool shouldLog(LogRecord record) {
    return filters.every((filter) => filter.shouldLog(record));
  }
}

/// 正则表达式过滤器
///
/// 根据日志消息是否匹配给定的正则表达式来决定是否记录日志
class RegexFilter implements AbstractLogFilter {
  final RegExp regex;

  /// 构造函数
  ///
  /// [regex] 是用于匹配日志消息的正则表达式
  RegexFilter(this.regex);

  @override
  bool shouldLog(LogRecord record) {
    return regex.hasMatch(record.message);
  }
}

/// 时间范围过滤器
///
/// 只记录在指定时间范围内的日志
class TimeRangeFilter implements AbstractLogFilter {
  final DateTime start;
  final DateTime end;

  /// 构造函数
  ///
  /// [start] 是时间范围的开始
  /// [end] 是时间范围的结束
  TimeRangeFilter(this.start, this.end);

  @override
  bool shouldLog(LogRecord record) {
    return record.timestamp.isAfter(start) && record.timestamp.isBefore(end);
  }
}
