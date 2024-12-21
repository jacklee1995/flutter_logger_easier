import '../core/log_record.dart';

/// 日志过滤器的抽象基类
///
/// 所有具体的日志过滤器实现都应该实现这个接口
abstract class LogFilter {
  /// 判断是否应该记录给定的日志记录
  ///
  /// [record] 是要判断的日志记录
  /// 返回 true 如果应该记录该日志，否则返回 false
  bool shouldLog(LogRecord record);
}

/// 复合过滤器
///
/// 组合多个过滤器，只有当所有过滤器都返回 true 时才记录日志
class CompositeFilter implements LogFilter {
  final List<LogFilter> filters;

  /// 构造函数
  ///
  /// [filters] 是要组合的过滤器列表
  CompositeFilter(this.filters);

  @override
  bool shouldLog(LogRecord record) {
    return filters.every((filter) => filter.shouldLog(record));
  }
}

/// 自定义过滤器
///
/// 使用提供的函数来决定是否记录日志
class CustomFilter implements LogFilter {
  final bool Function(LogRecord) predicate;

  /// 构造函数
  ///
  /// [predicate] 是用于判断是否记录日志的函数
  CustomFilter(this.predicate);

  @override
  bool shouldLog(LogRecord record) {
    return predicate(record);
  }
}

/// 正则表达式过滤器
///
/// 根据日志消息是否匹配给定的正则表达式来决定是否记录日志
class RegexFilter implements LogFilter {
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
class TimeRangeFilter implements LogFilter {
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