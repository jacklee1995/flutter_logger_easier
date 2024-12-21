import 'dart:async';
import '../filters/level_filter.dart';
import '../formatters/simple_formatter.dart';
import '../printers/console_printer.dart';
import '../printers/file_printer.dart';
import 'log_level.dart';
import 'log_record.dart';
import '../middleware/log_middlewares.dart';
import '../performance/performance_monitor.dart';
import '../error_reporting/error_reporter.dart';

/// 定义输出函数类型，可以为空
typedef OutputFunction = void Function(String)?;

/// 日志管理器，提供灵活的日志记录、性能监控和错误报告功能
///
/// 支持多种日志输出方式，包括控制台和文件，并可以自定义日志级别和处理器
class Logger {
  /// 单例实例，确保全局只有一个日志管理器
  static Logger? _instance;

  /// 输出函数，用于自定义日志输出
  // ignore: unused_field
  OutputFunction _outputFunction;

  /// 日志处理器列表，用于处理不同类型的日志输出
  final List<LogMiddleware> _handlers;

  /// 最小日志级别，低于此级别的日志将被忽略
  // ignore: unused_field
  LogLevel _minLevel;

  /// 可选的性能监控器，用于记录应用性能指标
  final PerformanceMonitor? _performanceMonitor;

  /// 可选的错误报告器，用于自动上报严重错误
  final ErrorReporter? _errorReporter;

  /// 私有构造函数，用于实现单例模式
  ///
  /// [middlewares] 日志处理器列表
  /// [minLevel] 最小日志级别
  /// [outputFunction] 自定义输出函数
  /// [errorReporter] 错误报告器
  /// [performanceMonitor] 性能监控器
  Logger._internal({
    required List<LogMiddleware> middlewares,
    LogLevel? minLevel,
    OutputFunction? outputFunction,
    ErrorReporter? errorReporter,
    PerformanceMonitor? performanceMonitor,
  })  : _handlers = middlewares,
        _outputFunction = outputFunction ?? print,
        _minLevel = minLevel ?? LogLevel.debug,
        _errorReporter = errorReporter,
        _performanceMonitor = performanceMonitor {
    // 如果传入了性能监控器，则初始化
    _performanceMonitor?.initialize();
  }

  /// 工厂构造函数，实现单例模式和灵活的日志配置
  ///
  /// [middlewares] 自定义日志处理器列表
  /// [errorReporter] 错误报告器
  /// [minLevel] 最小日志级别
  /// [outputFunction] 自定义输出函数
  /// [performanceMonitor] 性能监控器
  /// [logDirectory] 日志文件存储目录
  /// [baseFileName] 日志文件基础名称
  /// [maxFileSize] 单个日志文件最大大小
  /// [maxBackupIndex] 日志文件备份数量
  /// [compress] 是否压缩备份日志文件
  factory Logger({
    List<LogMiddleware>? middlewares,
    ErrorReporter? errorReporter,
    LogLevel? minLevel,
    OutputFunction? outputFunction,
    PerformanceMonitor? performanceMonitor,
    String? logDirectory,
    String? baseFileName,
    int? maxFileSize,
    int? maxBackupIndex,
    bool? compress,
  }) {
    // 设置默认最小日志级别
    final LogLevel defaultMinLevel = minLevel ?? LogLevel.debug;
    print('middlewares = $middlewares');
    print('logDirectory = $logDirectory');
    // 如果没有传入middlewares，但传入了logDirectory，自动创建文件日志中间件
    if (middlewares == null && logDirectory != null) {
      middlewares = [
        // 控制台日志
        LogMiddleware(
          printer: ConsolePrinter(
            useColor: true,
            maxLineLength: 120,
            outputFunction: outputFunction,
          ),
          formatter: SimpleFormatter(),
          filter: LevelFilter(defaultMinLevel),
        ),
        // 文件日志
        LogMiddleware(
          printer: FilePrinter(
            logDirectory: logDirectory,
            baseFileName: baseFileName ?? 'app.log',
            maxFileSize: maxFileSize ?? 5 * 1024 * 1024, // 5MB
            maxBackupIndex: maxBackupIndex ?? 3,
            compress: compress ?? true,
          ),
          filter: LevelFilter(LogLevel.info), // 文件只记录 info 及以上级别
          formatter: SimpleFormatter(),
        ),
      ];
    }

    // 如果没有传入middlewares且没有传入logDirectory，使用仅控制台输出
    middlewares ??= [
      LogMiddleware(
        printer: ConsolePrinter(
          useColor: true,
          maxLineLength: 120,
          outputFunction: outputFunction,
        ),
        formatter: SimpleFormatter(),
        filter: LevelFilter(defaultMinLevel),
      ),
    ];

    // 如果还没有实例，创建新实例
    _instance ??= Logger._internal(
      middlewares: middlewares,
      minLevel: defaultMinLevel,
      errorReporter: errorReporter,
      outputFunction: outputFunction,
      performanceMonitor: performanceMonitor,
    );

    return _instance!;
  }

  /// 重置单例实例，主要用于测试
  static void reset() {
    _instance = null;
  }

  /// 核心日志记录方法，处理所有级别的日志
  ///
  /// [level] 日志级别
  /// [message] 日志消息
  /// [error] 可选的错误对象
  /// [stackTrace] 可选的堆栈跟踪信息
  void log(LogLevel level, dynamic message,
      {dynamic error, StackTrace? stackTrace}) {
    final record = LogRecord(
      level,
      message.toString(),
      error: error,
      stackTrace: stackTrace,
    );

    // 分发日志到所有处理器
    for (final handler in _handlers) {
      handler.handle(record);
    }

    // 对于错误级别日志，自动上报
    if (level == LogLevel.error || level == LogLevel.critical) {
      _errorReporter?.reportError(error, stackTrace);
    }
  }

  /// 记录调试级别日志
  void trace(dynamic message) => log(LogLevel.trace, message);

  /// 记录调试级别日志
  void debug(dynamic message) => log(LogLevel.debug, message);

  /// 记录信息级别日志
  void info(dynamic message) => log(LogLevel.info, message);

  /// 记录警告级别日志
  void warn(dynamic message) => log(LogLevel.warn, message);

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

  /// 关闭所有日志处理器、性能监控器和错误报告器
  Future<void> close() async {
    for (final handler in _handlers) {
      await handler.close();
    }
    await _performanceMonitor?.close();
    await _errorReporter?.close();
  }

  /// 添加新的日志处理器
  ///
  /// [handler] 要添加的日志处理器
  void addHandler(LogMiddleware handler) {
    _handlers.add(handler);
  }

  /// 移除指定的日志处理器
  ///
  /// [handler] 要移除的日志处理器
  void removeHandler(LogMiddleware handler) {
    _handlers.remove(handler);
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
    print('Debug: Metrics = $metrics'); // 添加调试日志

    for (final entry in metrics.entries) {
      print('Debug: Logging metric ${entry.key} - ${entry.value}ms'); // 添加调试日志
      info('Performance: ${entry.key} - ${entry.value}ms');
    }
  }
}
