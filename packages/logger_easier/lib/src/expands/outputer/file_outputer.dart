import 'dart:io' show File, FileMode, Directory, FileSystemException;
import 'package:path/path.dart' as path;
import 'package:synchronized/synchronized.dart' show Lock;
import '../../core/log_level.dart' show LogLevel;
import '../../core/log_record.dart' show LogRecord;
import '../../log_rotate/interfaces/compression_handler.dart'
    show CompressionHandler;
import '../../log_rotate/interfaces/rotate_strategy.dart' show RotateStrategy;
import '../../log_rotate/rotate_manager.dart' show LogRotateManager;
import '../../log_rotate/strategies/size_based_strategy.dart'
    show SizeBasedStrategy;
import '../formatters/base_formatter.dart' show BaseFormatter;
import '../../interfaces/abstract_log_formatter.dart' show AbstractLogFormatter;
import '../../interfaces/async_outputer.dart' show AsyncOutputer;

/// 文件日志输出器
///
/// 负责将日志写入文件，并支持日志轮转功能。
/// 继承自 [AsyncOutputer]，实现异步写入和批处理优化。
class FilePrinter extends AsyncOutputer {
  String logDirectory;
  String baseFileName;
  final LogRotateManager rotateManager;
  final AbstractLogFormatter formatter;
  final _lock = Lock();

  bool _isInitialized = false;
  late File _currentLogFile;
  DateTime _lastRotateTime = DateTime.now();
  int _currentSize = 0;

  FilePrinter({
    required this.logDirectory,
    required this.baseFileName,
    RotateStrategy? rotateStrategy,
    CompressionHandler? compressionHandler,
    AbstractLogFormatter? formatter,
    super.maxQueueSize,
    super.flushInterval,
    super.maxRetries,
    super.retryDelay,
  })  : rotateManager = LogRotateManager(
          strategy:
              rotateStrategy ?? SizeBasedStrategy(maxSize: 10 * 1024 * 1024),
          compressionHandler: compressionHandler,
        ),
        formatter = formatter ?? BaseFormatter();

  @override
  Future<void> processRecord(LogRecord record) async {
    if (!_isInitialized) {
      await init();
    }

    await _lock.synchronized(() async {
      if (await _shouldRotate()) {
        await _rotateLog();
      }
      await _writeLog(record);
    });
  }

  @override
  Future<void> processBatch(List<LogRecord> records) async {
    if (!_isInitialized) {
      await init();
    }

    await _lock.synchronized(() async {
      if (await _shouldRotate()) {
        await _rotateLog();
      }

      // 批量写入优化
      final buffer = StringBuffer();
      for (final record in records) {
        buffer.writeln(formatter.format(record));
      }
      await _currentLogFile.writeAsString(
        buffer.toString(),
        mode: FileMode.append,
      );
    });
  }

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _lock.synchronized(() async {
        // 1. 确保日志目录存在
        final directory = Directory(logDirectory);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // 2. 生成带日期的文件名
        final baseFileNameWithoutExt =
            path.basenameWithoutExtension(baseFileName);
        final extension = path.extension(baseFileName);
        final dateStr = DateTime.now().toIso8601String().split('T')[0];
        final fileName = '${baseFileNameWithoutExt}-$dateStr$extension';

        // 3. 初始化当前日志文件
        _currentLogFile = File(path.join(logDirectory, fileName));

        // 4. 如果日志文件存在，获取当前大小
        if (await _currentLogFile.exists()) {
          _currentSize = await _currentLogFile.length();
        } else {
          await _currentLogFile.create();
          await _currentLogFile.writeAsString(
            '=== Log file created at ${DateTime.now()} ===\n',
            mode: FileMode.append,
          );
          _currentSize = 0;
        }

        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing file printer: $e');
      rethrow;
    }
  }

  /// 写入单条日志记录
  Future<void> _writeLog(LogRecord record) async {
    final formattedLog = formatter.format(record);
    final logSize = formattedLog.length;

    // 1. 检查写入后文件大小是否会超过限制
    if (_currentSize + logSize + 1 >
        (rotateManager.strategy as SizeBasedStrategy).maxSize) {
      print('Log file size will exceed limit, rotating...');
      await rotateManager.checkAndRotate(_currentLogFile);
      // 重新获取当前文件，因为可能已经被压缩
      _currentLogFile = File(path.join(logDirectory, baseFileName));
      // 确保文件存在
      if (!await _currentLogFile.exists()) {
        await _currentLogFile.create();
      }
      _currentSize = 0; // 重置文件大小
    }

    // 2. 写入新的日志
    await _currentLogFile.writeAsString(
      '$formattedLog\n',
      mode: FileMode.append,
    );
    _currentSize += logSize + 1; // 更新当前文件大小

    // 3. 写入后再次检查大小，确保不会超过限制
    if (_currentSize >= (rotateManager.strategy as SizeBasedStrategy).maxSize) {
      print('Log file size exceeded after write, rotating...');
      await rotateManager.checkAndRotate(_currentLogFile);
      _currentLogFile = File(path.join(logDirectory, baseFileName));
      _currentSize = 0;
    }
  }

  /// 执行日志轮转
  Future<void> _rotateLog() async {
    await rotateManager.checkAndRotate(_currentLogFile);
    _lastRotateTime = DateTime.now();
  }

  /// 检查是否需要轮转
  Future<bool> _shouldRotate() async {
    if (!_isInitialized) return false;
    return await rotateManager.shouldRotate(_currentLogFile, _currentSize);
  }

  @override
  Future<void> close() async {
    await _lock.synchronized(() async {
      _isInitialized = false;
      if (_currentLogFile.existsSync()) {
        await rotateManager.checkAndRotate(_currentLogFile);
      }
      await super.close();
    });
  }

  @override
  Map<String, dynamic> getStats() => {
        ...super.getStats(),
        'isInitialized': _isInitialized,
        'logDirectory': logDirectory,
        'baseFileName': baseFileName,
        'currentLogFile': _currentLogFile.path,
        'currentFileSize':
            _currentLogFile.existsSync() ? _currentLogFile.lengthSync() : 0,
        'lastRotateTime': _lastRotateTime.toIso8601String(),
      };

  // 基础实现
  @override
  String get name => 'FilePrinter';

  @override
  List<String> get supportedLevels =>
      ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'FATAL'];

  @override
  void setColorSupport(bool enabled) {} // 文件输出不支持颜色

  @override
  String formatMessage(dynamic message) => message.toString();

  @override
  String getLevelColor(LogLevel level) => '';

  @override
  String getLevelBgColor(LogLevel level) => '';

  @override
  String getLevelFgColor(LogLevel level) => '';

  @override
  Map<String, dynamic> get config => {
        'logDirectory': logDirectory,
        'baseFileName': baseFileName,
        'maxQueueSize': maxQueueSize,
        'flushInterval': flushInterval.inMilliseconds,
        'maxRetries': maxRetries,
        'retryDelay': retryDelay.inMilliseconds,
        'rotateStrategy': rotateManager.strategy.runtimeType.toString(),
        'compressionHandler':
            rotateManager.compressionHandler?.runtimeType.toString(),
      };

  @override
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    await _lock.synchronized(() async {
      bool needsReinitialization = false;

      // 检查是否需要重新初始化
      if (newConfig.containsKey('logDirectory') ||
          newConfig.containsKey('baseFileName')) {
        needsReinitialization = true;
      }

      // 如果需要重新初始化
      if (needsReinitialization) {
        await close();

        // 更新路径配置
        logDirectory = newConfig['logDirectory'] as String? ?? logDirectory;
        baseFileName = newConfig['baseFileName'] as String? ?? baseFileName;

        _isInitialized = false;
        await init();
      }

      // 更新其他配置
      if (newConfig.containsKey('maxQueueSize')) {
        // 这些配置的更新需要在 AsyncOutputer 中实现
        // 暂时不处理
      }
    });
  }

  @override
  String formatError(dynamic error, StackTrace? stackTrace) {
    final buffer = StringBuffer()
      ..writeln('=== Error Log Entry ===')
      ..writeln('Timestamp: ${DateTime.now().toIso8601String()}')
      ..writeln('Error: $error');

    if (stackTrace != null) {
      buffer
        ..writeln('Stack Trace:')
        ..writeln(stackTrace.toString());
    }

    buffer.writeln('=== End Error Log Entry ===');
    return buffer.toString();
  }
}
