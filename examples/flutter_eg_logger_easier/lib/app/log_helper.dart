import 'package:logger_easier/logger_easier.dart';
import 'size_based_logger.dart';
// import 'time_based_logger.dart';  // 预留基于时间的配置

/// 日志工具类
class Log {
  static Logger get _logger => SizeBasedLoggerConfig.instance.logger;
  // 如果需要使用基于时间的日志系统，注释上面的行，取消注释下面的行
  // static Logger get _logger => TimeBasedLoggerConfig.instance.logger;

  /// 记录跟踪级别日志
  static void trace(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.trace(message, error: error, stackTrace: stackTrace);

  /// 记录调试级别日志
  static void debug(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.debug(message, error: error, stackTrace: stackTrace);

  /// 记录信息级别日志
  static void info(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.info(message, error: error, stackTrace: stackTrace);

  /// 记录警告级别日志
  static void warn(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.warn(message, error: error, stackTrace: stackTrace);

  /// 记录错误级别日志
  static void error(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.error(message, error: error, stackTrace: stackTrace);

  /// 记录严重错误级别日志
  static void critical(String message,
          {dynamic error, StackTrace? stackTrace}) =>
      _logger.critical(message, error: error, stackTrace: stackTrace);

  /// 记录致命错误级别日志
  static void fatal(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.fatal(message, error: error, stackTrace: stackTrace);

  /// 测量异步操作性能
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) =>
      _logger.measurePerformance(operationName, operation);

  /// 测量同步操作性能
  static T measure<T>(String operationName, T Function() operation) =>
      _logger.measureSyncPerformance(operationName, operation);

  /// 记录性能指标
  static void logMetrics() => _logger.logPerformanceMetrics();
}
