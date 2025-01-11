import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:logger_easier/logger_easier.dart';

/// 日志配置数据类
class _LogConfig {
  final String logDirectory;
  final String baseFileName;
  final int maxFileSize;
  final int maxBackups;
  final Duration rotateInterval;

  const _LogConfig({
    required this.logDirectory,
    required this.baseFileName,
    required this.maxFileSize,
    required this.maxBackups,
    required this.rotateInterval,
  });
}

/// 日志管理器配置类
class LoggerConfig {
  /// 单例实例
  static LoggerConfig? _instance;
  late final Logger _logger;
  bool _isInitialized = false;

  /// 获取日志管理器实例
  Logger get logger {
    if (!_isInitialized) {
      throw StateError('LoggerConfig has not been initialized');
    }
    return _logger;
  }

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;

  /// 私有构造函数
  LoggerConfig._();

  /// 获取单例实例
  static LoggerConfig get instance => _instance ??= LoggerConfig._();

  /// 初始化日志管理器
  Future<void> initialize() async {
    if (_isInitialized) return;

    final logConfig = await _createLogConfig();
    _logger = await _createLogger(logConfig);
    _isInitialized = true;

    // 记录初始化完成
    _logger.info('Logger initialized successfully');
  }

  /// 创建日志配置
  Future<_LogConfig> _createLogConfig() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final logDirectory = path.join(appDocDir.path, 'logs');

    // 确保日志目录存在
    await Directory(logDirectory).create(recursive: true);

    return _LogConfig(
      logDirectory: logDirectory,
      baseFileName: 'app.log',
      maxFileSize: 10 * 1024 * 1024, // 10MB
      maxBackups: 7,
      rotateInterval: const Duration(days: 1),
    );
  }

  /// 创建日志管理器
  Future<Logger> _createLogger(_LogConfig config) async {
    // 创建控制台中间件
    final consoleMiddleware = ConsoleMiddleware(
      formatter: BaseFormatter(
        includeTimestamp: true,
        includeLevel: true,
        includeStackTrace: true,
      ),
      filter: CompositeFilter([
        LevelFilter(LogLevel.debug),
        // 可以添加其他过滤器
      ]),
    );

    // 创建文件中间件
    final fileMiddleware = FileMiddleware(
      logDirectory: config.logDirectory,
      baseFileName: config.baseFileName,
      rotateConfig: LogRotateConfig(
        strategy: TimeBasedStrategy(
          rotateInterval: config.rotateInterval,
          maxBackups: config.maxBackups,
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

    // 创建并配置日志管理器
    final logger = Logger(
      minLevel: LogLevel.trace,
      performanceMonitor: PerformanceMonitor(),
      errorReporter: ErrorReporter(
        onError: (error, stackTrace) {
          // 实现错误上报逻辑
          print('Error reported: $error');
        },
      ),
    );

    // 添加中间件
    logger.use(consoleMiddleware);
    logger.use(fileMiddleware);

    return logger;
  }

  /// 关闭日志管理器
  Future<void> close() async {
    await _logger.close();
  }
}
