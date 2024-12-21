import 'dart:io';
import 'package:path/path.dart' as path;
import '../core/log_record.dart';

class LogStorage {
  final String directory;
  final String baseFilename;
  final int maxFileSize; // 以字节为单位
  final int maxBackupCount;
  File? _currentFile;
  int _currentFileSize = 0;

  LogStorage({
    required this.directory,
    this.baseFilename = 'app.log',
    this.maxFileSize = 10 * 1024 * 1024, // 默认10MB
    this.maxBackupCount = 5,
  });

  Future<void> initialize() async {
    final dir = Directory(directory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _currentFile = File(path.join(directory, baseFilename));
    if (await _currentFile!.exists()) {
      _currentFileSize = await _currentFile!.length();
    }
  }

  Future<void> write(LogRecord record) async {
    if (_currentFile == null) {
      await initialize();
    }

    final logEntry = '${record.timestamp} [${record.level}] ${record.message}\n';
    final entrySize = logEntry.length;

    if (_currentFileSize + entrySize > maxFileSize) {
      await _rotateLog();
    }

    await _currentFile!.writeAsString(logEntry, mode: FileMode.append);
    _currentFileSize += entrySize;
  }

  Future<void> _rotateLog() async {
    for (var i = maxBackupCount - 1; i > 0; i--) {
      final file = File(path.join(directory, '$baseFilename.$i'));
      if (await file.exists()) {
        await file.rename(path.join(directory, '$baseFilename.${i + 1}'));
      }
    }

    await _currentFile!.rename(path.join(directory, '$baseFilename.1'));
    _currentFile = File(path.join(directory, baseFilename));
    _currentFileSize = 0;
  }
}