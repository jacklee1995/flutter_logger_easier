import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import '../core/log_level.dart';
import '../core/log_record.dart';
import '../utils/log_utils.dart';
import '../interfaces/base_printer.dart';

class FilePrinter implements BasePrinter {
  final String logDirectory;
  final String baseFileName;
  final int maxFileSize;
  final int maxBackupIndex;
  final bool compress;

  late File _currentLogFile;
  late IOSink _logSink;
  int _currentFileSize = 0;
  bool _isClosed = false;
  int _printedLogs = 0;
  bool _isInitialized = false;

  FilePrinter({
    required this.logDirectory,
    this.baseFileName = 'app.log',
    this.maxFileSize = 10 * 1024 * 1024, // 10 MB
    this.maxBackupIndex = 5,
    this.compress = true,
  }) {
    // 在构造函数中调用初始化
    _initializeLogFile();
  }

  Future<void> _initializeLogFile() async {
    try {
      // 确保目录存在
      final directory = Directory(logDirectory);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 创建日志文件
      _currentLogFile = File(path.join(logDirectory, baseFileName));
      _logSink = _currentLogFile.openWrite(mode: FileMode.append);

      _isInitialized = true;
    } catch (e) {
      print('Error initializing log file: $e');
      _isInitialized = false;
    }
  }

  @override
  Future<void> init() async {
    if (!_isInitialized) {
      await _initializeLogFile();
    }
  }

  @override
  String printf(LogRecord record) {
    // 如果初始化失败，使用控制台输出
    if (!_isInitialized) {
      final fallbackMessage = _formatLogRecord(record);
      print(fallbackMessage);
      return fallbackMessage;
    }

    final formattedMessage = _formatLogRecord(record);
    _writeToFile(formattedMessage);
    _printedLogs++;
    return formattedMessage;
  }

  void _writeToFile(String message) {
    try {
      _logSink.writeln(message);
      _currentFileSize += message.length;
      if (_currentFileSize >= maxFileSize) {
        _rotateLog();
      }
    } catch (e) {
      print('Error writing to log file: $e');
      _isInitialized = false;
    }
  }

  Future<void> _rotateLog() async {
    try {
      await _logSink.close();

      for (var i = maxBackupIndex - 1; i > 0; i--) {
        final file = File('${_currentLogFile.path}.$i');
        if (await file.exists()) {
          if (i == maxBackupIndex - 1 && compress) {
            await _compressLog(file);
          } else {
            await file.rename('${_currentLogFile.path}.${i + 1}');
          }
        }
      }

      await _currentLogFile.rename('${_currentLogFile.path}.1');
      _currentLogFile = File(path.join(logDirectory, baseFileName));
      _logSink = _currentLogFile.openWrite(mode: FileMode.append);
      _currentFileSize = 0;
    } catch (e) {
      print('Error rotating log file: $e');
      _isInitialized = false;
    }
  }

  Future<void> _compressLog(File logFile) async {
    try {
      final compressedFileName = '${logFile.path}.gz';
      final input = await logFile.readAsBytes();
      final gzipData = GZipEncoder().encode(input);
      await File(compressedFileName).writeAsBytes(gzipData);
      await logFile.delete();
    } catch (e) {
      print('Error compressing log file: $e');
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
    if (!_isClosed) {
      try {
        await _logSink.flush();
        await _logSink.close();
      } catch (e) {
        print('Error closing log file: $e');
      }
      _isClosed = true;
      _isInitialized = false;
    }
  }

  @override
  String get name => 'FilePrinter';

  @override
  Map<String, dynamic> get config => {
        'logDirectory': logDirectory,
        'baseFileName': baseFileName,
        'maxFileSize': maxFileSize,
        'maxBackupIndex': maxBackupIndex,
        'compress': compress,
      };

  @override
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    // 配置更新逻辑
  }

  @override
  bool get isClosed => _isClosed;

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
      'printedLogs': _printedLogs,
      'currentFileSize': _currentFileSize,
    };
  }

  @override
  void resetStats() {
    _printedLogs = 0;
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
