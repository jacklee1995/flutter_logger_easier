import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../interfaces/base_output.dart';

class FileOutput implements BaseOutput {
  final String directory;
  final String baseFilename;
  final int maxFileSize;
  final int maxBackupCount;
  final int bufferSize;
  final Duration flushInterval;

  late File _file;
  late IOSink _sink;
  final List<String> _buffer = [];
  Timer? _flushTimer;
  bool _isClosed = false;
  int _writtenLogs = 0;
  int _currentFileSize = 0;

  FileOutput({
    required this.directory,
    this.baseFilename = 'app.log',
    this.maxFileSize = 10 * 1024 * 1024, // 默认最大文件大小为10MB
    this.maxBackupCount = 5,
    this.bufferSize = 1000,
    this.flushInterval = const Duration(seconds: 30),
  }) {
    _initialize();
  }

  void _initialize() {
    final filePath = path.join(directory, baseFilename);
    _file = File(filePath);
    _sink = _file.openWrite(mode: FileMode.append);
    _startFlushTimer();
    _updateCurrentFileSize();
  }

  Future<void> _updateCurrentFileSize() async {
    if (await _file.exists()) {
      _currentFileSize = await _file.length();
    } else {
      _currentFileSize = 0;
    }
  }

  @override
  Future<void> write(String log) async {
    if (_isClosed) {
      throw StateError('FileOutput has been closed');
    }
    _buffer.add(log);
    _writtenLogs++;
    _currentFileSize += log.length;
    if (_buffer.length >= bufferSize || _currentFileSize > maxFileSize) {
      await flush();
    }
  }

  @override
  Future<void> flush() async {
    if (_buffer.isEmpty) return;

    if (_currentFileSize > maxFileSize) {
      await _rotateLog();
    }

    _sink.writeAll(_buffer, '\n');
    await _sink.flush();
    _buffer.clear();
    await _updateCurrentFileSize();
  }

  Future<void> _rotateLog() async {
    await close();

    for (var i = maxBackupCount - 1; i > 0; i--) {
      var file = File(path.join(directory, '$baseFilename.$i'));
      if (await file.exists()) {
        await file.rename(path.join(directory, '$baseFilename.${i + 1}'));
      }
    }

    await _file.rename(path.join(directory, '$baseFilename.1'));

    _initialize();
  }

  void _startFlushTimer() {
    _flushTimer = Timer.periodic(flushInterval, (_) => flush());
  }

  @override
  Future<void> close() async {
    if (!_isClosed) {
      _flushTimer?.cancel();
      await flush();
      await _sink.close();
      _isClosed = true;
    }
  }

  @override
  bool get isClosed => _isClosed;

  @override
  String get name => 'FileOutput';

  @override
  Map<String, dynamic> get config => {
        'directory': directory,
        'baseFilename': baseFilename,
        'maxFileSize': maxFileSize,
        'maxBackupCount': maxBackupCount,
        'bufferSize': bufferSize,
        'flushInterval': flushInterval.inSeconds,
      };

  @override
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    // 文件输出不支持动态配置更新
  }

  @override
  Future<bool> isReady() async {
    return !_isClosed && _file.existsSync();
  }

  @override
  Future<void> reopen() async {
    if (_isClosed) {
      _initialize();
    }
  }

  @override
  Map<String, dynamic> getStats() {
    return {
      'writtenLogs': _writtenLogs,
      'currentBufferSize': _buffer.length,
      'currentFileSize': _currentFileSize,
      'isClosed': _isClosed,
    };
  }

  @override
  void resetStats() {
    _writtenLogs = 0;
  }
}
