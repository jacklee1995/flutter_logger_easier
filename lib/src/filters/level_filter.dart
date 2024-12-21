import '../core/log_level.dart';
import '../core/log_record.dart';
import '../interfaces/log_filter.dart';

/// 基于日志级别的过滤器
class LevelFilter implements LogFilter {
  /// 最小日志级别
  LogLevel _minLevel;

  LevelFilter(this._minLevel);

  LogLevel get minLevel => _minLevel;

  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  @override
  bool shouldLog(LogRecord record) {
    return record.level.index >= _minLevel.index;
  }

  @override
  String toString() => 'LevelFilter(minLevel: $minLevel)';

  /// 创建一个只允许 TRACE 及以上级别日志的过滤器
  static LevelFilter trace() => LevelFilter(LogLevel.trace);

  /// 创建一个只允许 DEBUG 及以上级别日志的过滤器
  static LevelFilter debug() => LevelFilter(LogLevel.debug);

  /// 创建一个只允许 INFO 及以上级别日志的过滤器
  static LevelFilter info() => LevelFilter(LogLevel.info);

  /// 创建一个只允许 WARNING 及以上级别日志的过滤器
  static LevelFilter warn() => LevelFilter(LogLevel.warn);

  /// 创建一个只允许 ERROR 及以上级别日志的过滤器
  static LevelFilter error() => LevelFilter(LogLevel.error);

  /// 创建一个只允许 FATAL 级别日志的过滤器
  static LevelFilter fatal() => LevelFilter(LogLevel.critical);

  /// 创建一个允许所有级别日志的过滤器
  static LevelFilter all() => LevelFilter(LogLevel.debug);

  /// 创建一个不允许任何日志的过滤器
  static LevelFilter none() => LevelFilter(LogLevel.critical);

  /// 比较两个 LevelFilter 是否相等
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelFilter &&
          runtimeType == other.runtimeType &&
          minLevel == other.minLevel;

  @override
  int get hashCode => minLevel.hashCode;

  /// 创建一个新的 LevelFilter，其最小级别比当前过滤器高一级
  LevelFilter increaseLevel() {
    final nextIndex = (minLevel.index + 1).clamp(0, LogLevel.values.length - 1);
    return LevelFilter(LogLevel.values[nextIndex]);
  }

  /// 创建一个新的 LevelFilter，其最小级别比当前过滤器低一级
  LevelFilter decreaseLevel() {
    final prevIndex = (minLevel.index - 1).clamp(0, LogLevel.values.length - 1);
    return LevelFilter(LogLevel.values[prevIndex]);
  }

  /// 检查给定的日志级别是否会被此过滤器允许
  bool allowsLevel(LogLevel level) {
    return level.index >= minLevel.index;
  }
}
