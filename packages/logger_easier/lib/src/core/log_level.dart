enum LogLevel {
  trace,
  debug,
  info,
  warn,
  error,
  fatal,
  critical,
}

/// LogLevel 的扩展方法
extension LogLevelExtension on LogLevel {
  /// 获取日志级别的数值表示
  int get value {
    switch (this) {
      case LogLevel.trace:
        return 0;
      case LogLevel.debug:
        return 1;
      case LogLevel.info:
        return 2;
      case LogLevel.warn:
        return 3;
      case LogLevel.error:
        return 4;
      case LogLevel.critical:
        return 5;
      case LogLevel.fatal:
        return 6;
    }
  }

  /// 获取日志级别的字符串表示
  String get name {
    return toString().split('.').last;
  }

  /// 检查当前日志级别是否应该记录指定的日志级别
  bool shouldLog(LogLevel level) {
    return value <= level.value;
  }

  /// 从字符串解析日志级别
  static LogLevel fromString(String levelString) {
    return LogLevel.values.firstWhere(
      (level) => level.name.toLowerCase() == levelString.toLowerCase(),
      orElse: () => LogLevel.info,
    );
  }
}
