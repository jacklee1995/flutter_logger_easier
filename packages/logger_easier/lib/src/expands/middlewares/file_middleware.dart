import '../../core/log_level.dart' show LogLevel;
import '../../core/log_record.dart' show LogRecord;
import '../../interfaces/abstract_outputer.dart' show AbstractOutputer;
import '../../interfaces/abstract_log_filter.dart' show AbstractLogFilter;
import '../../interfaces/abstract_log_formatter.dart' show AbstractLogFormatter;
import '../../interfaces/abstract_log_middleware.dart'
    show AbstractLogMiddleware;
import '../../log_rotate/rotate_config.dart' show LogRotateConfig;
import '../../log_rotate/strategies/size_based_strategy.dart'
    show SizeBasedStrategy;
import '../../log_rotate/strategies/time_based_strategy.dart'
    show TimeBasedStrategy;
import '../../log_rotate/compression/gzip_handler.dart'
    show GzipCompressionHandler;
import '../formatters/inline_formatter.dart' show InlineFormatter;
import '../filters/level_filter.dart' show LevelFilter;
import '../outputer/file_outputer.dart' show FilePrinter;

/// 文件日志中间件
///
/// 用于将日志写入文件，支持日志轮转、压缩等功能。
class FileMiddleware extends AbstractLogMiddleware {
  final String logDirectory;
  final String baseFileName;
  final LogRotateConfig? rotateConfig;

  FileMiddleware({
    super.formatter,
    super.filter,
    required this.logDirectory,
    required this.baseFileName,
    this.rotateConfig,
  });

  @override
  AbstractOutputer createOutputer() {
    // 创建默认的轮转配置（如果未提供）
    final config = rotateConfig ??
        LogRotateConfig(
          strategy: SizeBasedStrategy(
            maxSize: 10 * 1024 * 1024, // 10MB
            maxBackups: 5,
          ),
          compressionHandler: GzipCompressionHandler(),
          delayCompress: true,
          enableStorageMonitoring: true,
        );

    return FilePrinter(
      logDirectory: logDirectory,
      baseFileName: baseFileName,
      rotateStrategy: config.strategy,
      compressionHandler: config.compressionHandler,
      formatter: formatter,
    );
  }

  @override
  AbstractLogFormatter createFormatter() {
    return InlineFormatter();
  }

  @override
  AbstractLogFilter createFilter() {
    return LevelFilter(LogLevel.debug);
  }

  @override
  Future<void> handle(LogRecord record) async {
    if (!filter.shouldLog(record)) {
      return;
    }

    final formattedRecord = record.copyWith(
      message: formatter.format(record),
    );
    outputer.printf(formattedRecord);
  }

  @override
  Future<void> close() async {
    await outputer.close();
  }

  /// 创建基于时间的日志中间件
  ///
  /// 工厂方法，用于创建一个使用基于时间轮转策略的文件日志中间件。
  static FileMiddleware createTimeBasedMiddleware({
    required String logDirectory,
    required String baseFileName,
    Duration rotateInterval = const Duration(days: 1),
    int maxBackups = 7,
    bool compress = true,
    AbstractLogFormatter? formatter,
    AbstractLogFilter? filter,
  }) {
    final config = LogRotateConfig(
      strategy: TimeBasedStrategy(
        rotateInterval: rotateInterval,
        maxBackups: maxBackups,
      ),
      compressionHandler: compress ? GzipCompressionHandler() : null,
    );

    return FileMiddleware(
      logDirectory: logDirectory,
      baseFileName: baseFileName,
      rotateConfig: config,
      formatter: formatter,
      filter: filter,
    );
  }

  /// 创建基于大小的日志中间件
  ///
  /// 工厂方法，用于创建一个使用基于大小轮转策略的文件日志中间件。
  static FileMiddleware createSizeBasedMiddleware({
    required String logDirectory,
    required String baseFileName,
    int maxSize = 10 * 1024 * 1024,
    int maxBackups = 5,
    bool compress = true,
    AbstractLogFormatter? formatter,
    AbstractLogFilter? filter,
    LogRotateConfig? rotateConfig,
    bool includeDate = true,
    bool includeTime = false,
    String separator = '_',
  }) {
    final config = rotateConfig ??
        LogRotateConfig(
          strategy: SizeBasedStrategy(
            maxSize: maxSize,
            maxBackups: maxBackups,
          ),
          compressionHandler: compress ? GzipCompressionHandler() : null,
          includeDate: includeDate,
          includeTime: includeTime,
          separator: separator,
        );

    return FileMiddleware(
      logDirectory: logDirectory,
      baseFileName: baseFileName,
      rotateConfig: config,
      formatter: formatter,
      filter: filter,
    );
  }
}
