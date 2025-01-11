import 'dart:async';

import '../expands/middlewares/file_middleware.dart';
import '../log_rotate/rotate_config.dart';
import 'log_level.dart' show LogLevel;
import 'log_record.dart' show LogRecord;

import '../interfaces/abstract_log_middleware.dart' show AbstractLogMiddleware;
import '../performance/performance_monitor.dart' show PerformanceMonitor;
import '../error_reporting/error_reporter.dart' show ErrorReporter;

/// 定义输出函数类型,可以为空
typedef OutputFunction = void Function(String)?;

/// 日志管理器,提供灵活的日志记录、性能监控和错误报告功能
///
/// 支持多种日志输出方式,包括控制台和文件,并可以自定义日志级别和处理器
class Logger {
  /// 单例实例,确保全局只有一个日志管理器
  static Logger? _instance;

  /// 输出函数,用于自定义日志输出
  // ignore: unused_field
  OutputFunction _outputFunction;

  /// 日志处理器列表,用于处理不同类型的日志输出
  final List<AbstractLogMiddleware> _middlewares = [];

  /// 最小日志级别,低于此级别的日志将被忽略
  LogLevel _minLevel;

  /// 可选的性能监控器,用于记录应用性能指标
  final PerformanceMonitor? _performanceMonitor;

  /// 可选的错误报告器,用于自动上报严重错误
  final ErrorReporter? _errorReporter;

  /// 私有构造函数,用于实现单例模式
  ///
  /// [minLevel] 最小日志级别
  /// [outputFunction] 自定义输出函数
  /// [errorReporter] 错误报告器
  /// [performanceMonitor] 性能监控器
  Logger._internal({
    LogLevel minLevel = LogLevel.debug,
    OutputFunction? outputFunction,
    ErrorReporter? errorReporter,
    PerformanceMonitor? performanceMonitor,
  })  : _outputFunction = outputFunction ?? print,
        _minLevel = minLevel,
        _errorReporter = errorReporter,
        _performanceMonitor = performanceMonitor {
    // 如果传入了性能监控器,则初始化
    _performanceMonitor?.initialize();
  }

  /// 工厂构造函数,实现单例模式和灵活的日志配置
  ///
  /// [errorReporter] 错误报告器
  /// [minLevel] 最小日志级别
  /// [outputFunction] 自定义输出函数
  /// [performanceMonitor] 性能监控器
  /// [logDirectory] 日志文件存储目录
  /// [baseFileName] 日志文件基础名称
  /// [rotateConfig] 日志文件轮转配置
  factory Logger({
    ErrorReporter? errorReporter,
    LogLevel minLevel = LogLevel.debug,
    OutputFunction? outputFunction,
    PerformanceMonitor? performanceMonitor,
    String? logDirectory,
    String baseFileName = 'app.log',
    LogRotateConfig? rotateConfig,
  }) {
    _instance ??= Logger._internal(
      minLevel: minLevel,
      errorReporter: errorReporter,
      outputFunction: outputFunction,
      performanceMonitor: performanceMonitor,
    );

    if (logDirectory != null) {
      _instance!.use(FileMiddleware.createSizeBasedMiddleware(
        logDirectory: logDirectory,
        baseFileName: baseFileName,
        rotateConfig: rotateConfig,
      ));
    }

    return _instance!;
  }

  /// 重置单例实例,主要用于测试
  static void reset() {
    _instance = null;
  }

  /// 中间件的安装方法
  void use(AbstractLogMiddleware middleware) {
    _middlewares.add(middleware);
  }

  /// 核心日志记录方法,处理所有级别的日志
  ///
  /// [level] 日志级别
  /// [message] 日志消息
  /// [error] 可选的错误对象
  /// [stackTrace] 可选的堆栈跟踪信息
  void log(LogLevel level, dynamic message,
      {dynamic error, StackTrace? stackTrace}) {
    // 如果日志级别低于最小级别,忽略该条日志
    if (level.index < _minLevel.index) return;

    final record = LogRecord(
      level,
      message.toString(),
      error: error,
      stackTrace: stackTrace,
    );

    // 分发日志到所有中间件
    for (final middleware in _middlewares) {
      if (middleware.filter.shouldLog(record)) {
        middleware.outputer.printf(record);
      }
    }

    // 对于错误级别日志,自动上报
    if (level == LogLevel.error || level == LogLevel.critical) {
      _errorReporter?.reportError(error, stackTrace);
    }
  }

  /// 记录追踪级别日志
  void trace(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      log(LogLevel.trace, message, error: error, stackTrace: stackTrace);

  /// 记录调试级别日志
  void debug(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      log(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  /// 记录信息级别日志
  void info(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      log(LogLevel.info, message, error: error, stackTrace: stackTrace);

  /// 记录警告级别日志
  void warn(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      log(LogLevel.warn, message, error: error, stackTrace: stackTrace);

  /// 记录错误级别日志
  ///
  /// [error] 可选的错误对象
  /// [stackTrace] 可选的堆栈跟踪信息
  void error(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  /// 记录关键错误级别日志
  ///
  /// [error] 可选的错误对象
  /// [stackTrace] 可选的堆栈跟踪信息
  void critical(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      log(LogLevel.critical, message, error: error, stackTrace: stackTrace);

  /// 记录致命错误级别日志
  ///
  /// [error] 可选的错误对象
  /// [stackTrace] 可选的堆栈跟踪信息
  void fatal(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      log(LogLevel.fatal, message, error: error, stackTrace: stackTrace);

  /// 关闭所有日志中间件、性能监控器和错误报告器
  Future<void> close() async {
    for (final middleware in _middlewares) {
      await middleware.close();
    }
    await _performanceMonitor?.close();
    await _errorReporter?.close();
  }

  /// 移除指定的日志中间件
  ///
  /// [middleware] 要移除的日志中间件
  void removeMiddleware(AbstractLogMiddleware middleware) {
    _middlewares.remove(middleware);
  }

  /// 异步性能度量
  ///
  /// [operationName] 操作名称
  /// [operation] 要测量性能的异步操作
  ///
  /// 返回操作的执行结果
  Future<T> measurePerformance<T>(
      String operationName, Future<T> Function() operation) async {
    // 仅在有性能监控器时才测量性能
    if (_performanceMonitor == null) {
      return await operation();
    }

    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } catch (e, s) {
      // 捕获并处理异常,确保性能度量不影响正常业务逻辑
      error('Error in $operationName: $e', error: e, stackTrace: s);
      rethrow;
    } finally {
      stopwatch.stop();
      _performanceMonitor.recordMetric(
          operationName, stopwatch.elapsedMilliseconds);
    }
  }

  /// 同步性能度量
  ///
  /// [operationName] 操作名称
  /// [operation] 要测量性能的同步操作
  ///
  /// 返回操作的执行结果
  T measureSyncPerformance<T>(String operationName, T Function() operation) {
    // 仅在有性能监控器时才测量性能
    if (_performanceMonitor == null) {
      return operation();
    }

    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } catch (e, s) {
      // 捕获并处理异常,确保性能度量不影响正常业务逻辑
      error('Error in $operationName: $e', error: e, stackTrace: s);
      rethrow;
    } finally {
      stopwatch.stop();
      _performanceMonitor.recordMetric(
          operationName, stopwatch.elapsedMilliseconds);
    }
  }

  /// 记录性能指标
  ///
  /// 将收集到的性能指标以日志形式输出
  void logPerformanceMetrics() {
    // 仅在有性能监控器时才记录性能指标
    if (_performanceMonitor == null) return;

    final metrics = _performanceMonitor.getMetrics();
    debug('Performance metrics: $metrics');

    for (final entry in metrics.entries) {
      info('Performance: ${entry.key} - ${entry.value}ms');
    }
  }
}
