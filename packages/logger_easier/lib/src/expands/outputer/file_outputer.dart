import 'dart:async';
import 'dart:io' show File, FileMode, Directory, FileSystemException;
import 'package:path/path.dart' as path;
import '../../core/log_level.dart' show LogLevel;
import '../../core/log_record.dart' show LogRecord;
import '../../log_rotate/interfaces/compression_handler.dart'
    show CompressionHandler;
import '../../log_rotate/interfaces/rotate_strategy.dart' show RotateStrategy;
import '../../utils/log_utils.dart' show LogUtils;
import '../../interfaces/abstract_outputer.dart' show AbstractOutputer;
import '../../log_rotate/rotate_manager.dart' show LogRotateManager;
import '../../log_rotate/strategies/size_based_strategy.dart'
    show SizeBasedStrategy;

class FilePrinter implements AbstractOutputer {
  final String logDirectory;
  final String baseFileName;
  final LogRotateManager rotateManager;
  bool _isInitialized = false;
  late File _currentLogFile;

  FilePrinter({
    required this.logDirectory,
    required this.baseFileName,
    RotateStrategy? rotateStrategy,
    CompressionHandler? compressionHandler,
  }) : rotateManager = LogRotateManager(
          strategy:
              rotateStrategy ?? SizeBasedStrategy(maxSize: 10 * 1024 * 1024),
          compressionHandler: compressionHandler,
        );

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. 确保日志目录存在
      final directory = Directory(logDirectory);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 2. 初始化当前日志文件
      _currentLogFile = File(path.join(logDirectory, baseFileName));

      // 3. 如果日志文件不存在，创建它
      if (!await _currentLogFile.exists()) {
        await _currentLogFile.create();
        // 写入日志文件头部信息
        await _currentLogFile.writeAsString(
          '=== Log file created at ${DateTime.now()} ===\n',
          mode: FileMode.append,
        );
      }

      // 4. 检查并执行必要的日志轮转
      await rotateManager.checkAndRotate(_currentLogFile);

      _isInitialized = true;
    } catch (e, stackTrace) {
      _isInitialized = false;
      throw FileSystemException(
        'Failed to initialize log file: $e',
        logDirectory,
      );
    }
  }

  @override
  String printf(LogRecord record) {
    if (!_isInitialized) {
      throw StateError('FilePrinter not initialized. Call init() first.');
    }

    final message = _formatLogRecord(record);
    _writeToFile(message);
    return message;
  }

  void _writeToFile(String message) async {
    if (!_isInitialized) {
      throw StateError('FilePrinter not initialized. Call init() first.');
    }

    try {
      await _currentLogFile.writeAsString(
        '$message\n',
        mode: FileMode.append,
      );
      await rotateManager.checkAndRotate(_currentLogFile);
    } catch (e, stackTrace) {
      // 写入失败时的处理
      print('Failed to write to log file: $e\n$stackTrace');
      // 可以考虑重新初始化或者使用备用输出方式
    }
  }

  String _formatLogRecord(LogRecord record) {
    final buffer = StringBuffer();
    buffer.write('${LogUtils.getTimestamp()} ');
    buffer.write('[${LogUtils.getLevelString(record.level)}] ');
    buffer.write(record.message);

    if (record.error != null) {
      buffer.write('\nError: ${record.error}');
    }

    if (record.stackTrace != null) {
      buffer.write('\nStack Trace:\n${record.stackTrace}');
    }

    return buffer.toString();
  }

  @override
  Future<void> close() async {
    _isInitialized = false;
    // 在关闭前执行最后一次轮转检查
    if (_currentLogFile.existsSync()) {
      await rotateManager.checkAndRotate(_currentLogFile);
    }
  }

  @override
  String get name => 'FilePrinter';

  @override
  Map<String, dynamic> get config => {
        'logDirectory': logDirectory,
        'baseFileName': baseFileName,
      };

  @override
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    // 如果配置发生变化，可能需要重新初始化
    if (newConfig.containsKey('logDirectory') ||
        newConfig.containsKey('baseFileName')) {
      await close();
      _isInitialized = false;
      await init();
    }
  }

  @override
  bool get isClosed => !_isInitialized;

  @override
  List<String> get supportedLevels =>
      ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'FATAL'];

  @override
  void setColorSupport(bool enabled) {
    // 文件打印器不支持颜色
  }

  @override
  Map<String, dynamic> getStats() {
    return {
      'isInitialized': _isInitialized,
      'logDirectory': logDirectory,
      'baseFileName': baseFileName,
      'currentLogFile': _currentLogFile.path,
      'currentFileSize':
          _currentLogFile.existsSync() ? _currentLogFile.lengthSync() : 0,
    };
  }

  @override
  void resetStats() {
    // 不需要重置统计信息
  }

  @override
  String formatError(dynamic error, StackTrace? stackTrace) {
    return 'Error: $error\nStackTrace: $stackTrace';
  }

  @override
  String formatMessage(dynamic message) => message.toString();

  @override
  String getLevelColor(LogLevel level) {
    // 文件打印器不使用颜色
    return '';
  }

  @override
  String getLevelBgColor(LogLevel level) {
    // 文件打印器不使用颜色
    return '';
  }

  @override
  String getLevelFgColor(LogLevel level) {
    // 文件打印器不使用颜色
    return '';
  }
}
