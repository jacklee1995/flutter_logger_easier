import 'dart:io' show Directory, File;
import 'package:intl/intl.dart' show DateFormat;
import 'package:path/path.dart' as path;

import 'interfaces/compression_handler.dart' show CompressionHandler;
import 'interfaces/rotate_strategy.dart' show RotateStrategy;

/// 日志轮转管理器
///
/// 负责管理日志文件的轮转逻辑。结合轮转策略 [RotateStrategy] 和压缩处理器 [CompressionHandler]，实现对日志文件的高效管理。
///
/// 特性:
/// - 支持大小和时间两种轮转策略。
/// - 可选延迟压缩，避免轮转时立即压缩导致性能问题。
///
/// 参数:
/// - [strategy] 日志轮转策略。
/// - [compressionHandler] 压缩处理器，可选。
/// - [delayCompress] 是否延迟压缩，默认值为 true。
///
/// 方法:
/// - [checkAndRotate] 检查并执行日志轮转。
/// - [_rotateLog] 执行日志文件的轮转逻辑。
/// - [_compressLog] 对日志文件进行压缩。
class LogRotateManager {
  final RotateStrategy strategy;
  final CompressionHandler? compressionHandler;
  late String compressedExtension;
  final bool delayCompress;
  final bool includeDate;
  final bool includeTime;
  final String separator;
  final String? dateTimeFormat;
  final String archiveDir;

  DateTime _lastRotateTime = DateTime.now();
  int _currentSize = 0;

  LogRotateManager({
    required this.strategy,
    this.compressionHandler,
    this.delayCompress = true,
    this.includeDate = true,
    this.includeTime = false,
    this.separator = '_',
    this.dateTimeFormat,
    String? archiveDir,
  })  : archiveDir = archiveDir ?? 'archives',
        compressedExtension =
            compressionHandler?.compressedExtension ?? '.gz' {}

  /// 更新当前文件大小
  Future<void> updateCurrentSize(File logFile) async {
    if (await logFile.exists()) {
      _currentSize = await logFile.length();
    } else {
      _currentSize = 0;
    }
  }

  /// 增加当前文件大小
  void addSize(int size) {
    _currentSize += size;
  }

  /// 确保归档目录存在
  Future<Directory> _ensureArchiveDirectory(String baseDir) async {
    final archivePath = path.join(baseDir, archiveDir);
    final archiveDirectory = Directory(archivePath);
    if (!await archiveDirectory.exists()) {
      await archiveDirectory.create(recursive: true);
    }
    return archiveDirectory;
  }

  /// 生成压缩文件的时间戳
  String _generateTimestamp() {
    final now = DateTime.now();
    if (dateTimeFormat != null) {
      return DateFormat(dateTimeFormat!).format(now);
    }
    return now.microsecondsSinceEpoch.toString();
  }

  /// 检查并执行日志轮转
  ///
  /// 根据当前日志文件的大小及最后轮转时间判断是否需要进行日志轮转。如果需要轮转，则执行日志轮转操作。
  ///
  /// 参数:
  /// - [logFile] 当前的日志文件。
  ///
  /// 返回:
  /// - 无返回值。轮转成功时，会重命名日志文件，并根据配置执行压缩及清理过期日志。
  Future<void> checkAndRotate(File logFile) async {
    try {
      await updateCurrentSize(logFile);

      if (strategy.shouldRotate(logFile, _currentSize, _lastRotateTime)) {
        await _rotateLog(logFile);
        _lastRotateTime = DateTime.now();
        _currentSize = 0;
      }
    } catch (e, s) {
      print('Error checking file size: $e\n$s');
    }
  }

  /// 检查并执行日志轮转
  Future<bool> shouldRotate(File logFile, int currentSize) async {
    if (!await logFile.exists()) return false;
    _currentSize = currentSize;
    // 策略决定轮转
    final shouldRotate =
        strategy.shouldRotate(logFile, _currentSize, _lastRotateTime);
    if (shouldRotate) {
      _lastRotateTime = DateTime.now();
    }

    return shouldRotate;
  }

  /// 执行日志轮转
  ///
  /// 根据轮转策略，将当前日志文件进行轮转（重命名）。如果配置了压缩处理器，并且需要进行压缩，则执行压缩操作。
  ///
  /// 参数:
  /// - [logFile] 当前需要进行轮转的日志文件。
  ///
  /// 返回:
  /// - 无返回值。如果轮转过程中出现异常，会捕获并输出错误，但不会影响日志记录功能。
  Future<void> _rotateLog(File currentLogFile) async {
    final directory = currentLogFile.parent;
    final archiveDirectory = await _ensureArchiveDirectory(directory.path);
    final baseFileName = path.basenameWithoutExtension(currentLogFile.path);
    final extension = path.extension(currentLogFile.path);

    // 1. 获取所有轮转的日志文件并按索引排序
    final files = await _getRotatedFiles(directory, baseFileName, extension);
    files.sort((a, b) => _getRotationIndex(a).compareTo(_getRotationIndex(b)));

    // 2. 如果已经达到最大备份数，进行压缩
    if (files.length >= strategy.maxBackups) {
      if (compressionHandler != null) {
        // 重命名当前日志文件为最后一个索引
        final lastIndex = strategy.maxBackups;
        final lastRotatedFile = File(path.join(
          directory.path,
          '$baseFileName.$lastIndex$extension',
        ));
        await currentLogFile.rename(lastRotatedFile.path);

        // 获取所有需要压缩的文件（包括刚重命名的文件）
        final allFiles =
            await _getRotatedFiles(directory, baseFileName, extension);

        // TODO:压缩所有文件未必是.gz，得定义的压缩处理器才能决定
        final timestamp = _generateTimestamp();
        final compressedFileName = '$baseFileName-$timestamp.gz';
        final compressedFile = File(path.join(
          archiveDirectory.path,
          compressedFileName,
        ));

        await _compressLogs(allFiles, compressedFile);

        // 删除所有已压缩的文件
        for (final file in allFiles) {
          await file.delete();
        }

        // 清理过期的压缩文件
        await _cleanupOldArchives(archiveDirectory, baseFileName);

        // 创建新的空日志文件
        await currentLogFile.create();
        _currentSize = 0;
        return;
      }
    } else {
      // 3. 如果未达到最大备份数，执行常规轮转
      // 从最大索引开始，依次重命名文件
      for (var i = files.length - 1; i >= 0; i--) {
        final file = files[i];
        final currentIndex = _getRotationIndex(file);
        final newPath = path.join(
          directory.path,
          '$baseFileName.${currentIndex + 1}$extension',
        );
        await file.rename(newPath);
      }

      // 重命名当前日志文件为 .1
      final firstRotatedFile = File(path.join(
        directory.path,
        '$baseFileName.1$extension',
      ));
      await currentLogFile.rename(firstRotatedFile.path);

      // 创建新的空日志文件
      await currentLogFile.create();
      _currentSize = 0;
    }
  }

  /// 清理过期的压缩文件
  Future<void> _cleanupOldArchives(
      Directory archiveDir, String baseFileName) async {
    final files = await archiveDir
        .list()
        .where((entity) =>
            entity is File &&
            path.basename(entity.path).startsWith(baseFileName) &&
            path.basename(entity.path).endsWith(compressedExtension))
        .map((entity) => entity as File)
        .toList();

    // 按修改时间排序
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    // 保留最新的 maxBackups 个文件
    if (files.length > strategy.maxBackups) {
      for (var i = strategy.maxBackups; i < files.length; i++) {
        await files[i].delete();
      }
    }
  }

  /// 获取文件的轮转索引
  int _getRotationIndex(File file) {
    final fileName = path.basenameWithoutExtension(file.path);
    final parts = fileName.split('.');
    if (parts.length > 1) {
      try {
        return int.parse(parts.last);
      } catch (e) {
        return -1;
      }
    }
    return 0; // 当前日志文件
  }

  /// 获取所有轮转的日志文件
  Future<List<File>> _getRotatedFiles(
    Directory directory,
    String baseFileName,
    String extension,
  ) async {
    final allFiles = await directory
        .list()
        .where((entity) =>
            entity is File &&
            path.basename(entity.path).startsWith('$baseFileName.') &&
            path.basename(entity.path).endsWith(extension) &&
            _isRotatedLogFile(entity, baseFileName))
        .map((entity) => entity as File)
        .toList();
    return allFiles;
  }

  /// 检查文件是否为轮转的日志文件
  bool _isRotatedLogFile(File file, String baseFileName) {
    final fileName = path.basenameWithoutExtension(file.path);
    if (!fileName.startsWith('$baseFileName.')) return false;

    final indexStr = fileName.substring(baseFileName.length + 1);
    return int.tryParse(indexStr) != null;
  }

  /// 压缩多个日志文件
  Future<void> _compressLogs(List<File> files, File compressedFile) async {
    if (compressionHandler == null) return;

    // 创建临时文件合并所有日志
    final tempFile = File('${compressedFile.path}.temp');
    final sink = tempFile.openWrite();

    for (final file in files) {
      final content = await file.readAsString();
      sink.writeln(content);
    }

    await sink.close();

    // 压缩合并后的文件
    await compressionHandler!.compress(tempFile, compressedFile);
    await tempFile.delete();
  }
}
