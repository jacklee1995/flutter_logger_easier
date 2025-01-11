import 'dart:async';
import 'dart:collection' show Queue;
import 'dart:io' show File, FileMode, Directory, FileSystemException;
import 'package:path/path.dart' as path;
import 'package:synchronized/synchronized.dart' show Lock;
import '../../core/log_level.dart' show LogLevel;
import '../../core/log_record.dart' show LogRecord;
import '../../log_rotate/interfaces/compression_handler.dart'
    show CompressionHandler;
import '../../log_rotate/interfaces/rotate_strategy.dart' show RotateStrategy;
import '../../interfaces/abstract_outputer.dart' show AbstractOutputer;
import '../../log_rotate/rotate_manager.dart' show LogRotateManager;
import '../../log_rotate/strategies/size_based_strategy.dart'
    show SizeBasedStrategy;
import '../formatters/base_formatter.dart' show BaseFormatter;
import '../../interfaces/abstract_log_formatter.dart' show AbstractLogFormatter;

class FilePrinter implements AbstractOutputer {
  final String logDirectory;
  final String baseFileName;
  final LogRotateManager rotateManager;
  final AbstractLogFormatter formatter;
  bool _isInitialized = false;
  late File _currentLogFile;
  final Queue<String> _writeQueue = Queue();
  final StreamController<void> _writeController = StreamController.broadcast();
  final _lock = Lock();

  FilePrinter({
    required this.logDirectory,
    required this.baseFileName,
    RotateStrategy? rotateStrategy,
    CompressionHandler? compressionHandler,
    AbstractLogFormatter? formatter,
  })  : rotateManager = LogRotateManager(
          strategy:
              rotateStrategy ?? SizeBasedStrategy(maxSize: 10 * 1024 * 1024),
          compressionHandler: compressionHandler,
        ),
        formatter = formatter ?? BaseFormatter();

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
      });

      // 启动异步写入处理
      _startWriteProcessor();

      _isInitialized = true;
    } catch (e, stackTrace) {
      _isInitialized = false;
      throw FileSystemException(
        'Failed to initialize log file: $e\n$stackTrace',
        logDirectory,
      );
    }
  }

  void _startWriteProcessor() {
    Timer.periodic(Duration(milliseconds: 100), (_) {
      if (_writeQueue.isEmpty) return;

      _lock.synchronized(() async {
        while (_writeQueue.isNotEmpty) {
          final content = _writeQueue.removeFirst();
          await _currentLogFile.writeAsString(
            content,
            mode: FileMode.append,
          );
        }
        _writeController.add(null);
      });
    });
  }

  @override
  String printf(LogRecord record) {
    final output = formatter.format(record);
    _writeQueue.add('$output\n');
    return output;
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
