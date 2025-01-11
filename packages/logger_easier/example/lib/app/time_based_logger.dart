import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:logger_easier/logger_easier.dart';

/// 基于时间的日志配置类
class TimeBasedLoggerConfig {
  static TimeBasedLoggerConfig? _instance;
  late final Logger _logger;
  bool _isInitialized = false;

  /// 获取日志管理器实例
  Logger get logger {
    if (!_isInitialized) {
      throw StateError('TimeBasedLoggerConfig has not been initialized');
    }
    return _logger;
  }

  bool get isInitialized => _isInitialized;

  TimeBasedLoggerConfig._();

  static TimeBasedLoggerConfig get instance =>
      _instance ??= TimeBasedLoggerConfig._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    final appDocDir = await getApplicationDocumentsDirectory();
    final logDirectory = path.join(appDocDir.path, 'logs', 'time_based');
    await Directory(logDirectory).create(recursive: true);

    // 创建控制台中间件
    final consoleMiddleware = ConsoleMiddleware(
      formatter: BaseFormatter(
        includeTimestamp: true,
        includeLevel: true,
        includeStackTrace: true,
      ),
      filter: LevelFilter(LogLevel.debug),
    );

    // 创建基于时间的文件中间件
    final fileMiddleware = FileMiddleware(
      logDirectory: logDirectory,
      baseFileName: 'app.log',
      rotateConfig: LogRotateConfig(
        strategy: TimeBasedStrategy(
          rotateInterval: const Duration(days: 1),
          maxBackups: 7,
        ),
        compressionHandler: GzipCompressionHandler(
          onProgress: (message) => print('Compression progress: $message'),
        ),
        enableStorageMonitoring: true,
        minimumFreeSpace: 100 * 1024 * 1024, // 100MB
      ),
      formatter: BaseFormatter(
        includeTimestamp: true,
        includeLevel: true,
        includeStackTrace: true,
      ),
      filter: LevelFilter(LogLevel.info),
    );

    // 创建日志管理器
    _logger = Logger(
      minLevel: LogLevel.trace,
      performanceMonitor: PerformanceMonitor(),
      errorReporter: ErrorReporter(
        onError: (error, stackTrace) {
          print('Error reported: $error');
        },
      ),
    );

    // 添加中间件
    _logger.use(consoleMiddleware);
    _logger.use(fileMiddleware);

    _isInitialized = true;
    _logger.info('Time-based logger initialized successfully');
  }

  Future<void> close() async {
    if (_isInitialized) {
      await _logger.close();
    }
  }
}
