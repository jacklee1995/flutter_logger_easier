import 'dart:io' show Directory, File;
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

import '../interfaces/rotate_strategy.dart' show RotateStrategy;

/// 基于大小的日志轮转策略
///
/// 当日志文件大小超过指定阈值时触发轮转。此策略支持限制备份的最大数量，以避免占用过多存储空间。
///
/// 参数:
/// - [maxSize] 最大文件大小（字节）。当日志文件大小超过此阈值时触发轮转。
/// - [maxBackups] 最大备份数量，默认值为5。超过此数量的旧日志将被删除。
class SizeBasedStrategy implements RotateStrategy {
  /// 最大文件大小(字节)
  final int maxSize;

  /// 最大备份数量
  @override
  final int maxBackups;

  /// 上次检查日期
  DateTime? _lastCheckDate;

  /// 构造函数
  ///
  /// 创建一个新的基于大小的日志轮转策略实例。
  ///
  /// 参数:
  /// - [maxSize] 最大文件大小（字节），默认值为99MB。
  /// - [maxBackups] 最大备份数量，默认值为99。
  SizeBasedStrategy({
    int? maxSize,
    this.maxBackups = 99,
  }) : maxSize = maxSize ?? (99 * 1024 * 1024); // 默认99MB

  /// 检查是否需要进行日志轮转
  ///
  /// 根据当前日志文件的大小和上次轮转时间，判断是否需要执行轮转操作。
  ///
  /// 参数:
  /// - [logFile] 当前的日志文件。
  /// - [currentSize] 当前日志文件的大小。
  /// - [lastRotateTime] 上次轮转的时间。
  ///
  /// 返回:
  /// - 如果当前文件大小超过 [maxSize]，返回 `true`，表示需要进行轮转；否则返回 `false`。
  @override
  bool shouldRotate(File logFile, int currentSize, DateTime lastRotateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 检查是否是新的一天
    if (_lastCheckDate == null || _lastCheckDate != today) {
      _lastCheckDate = today;

      // 如果文件存在且不为空，在每天第一次写入时进行轮转
      if (logFile.existsSync() && currentSize > 0) {
        print('Daily check: rotating log file at the start of new day');
        return true;
      }
    }

    // 检查文件大小
    final shouldRotate = currentSize >= maxSize;
    if (shouldRotate) {
      print(
          'Log rotation needed: current size ($currentSize bytes) >= max size ($maxSize bytes)');
    }
    return shouldRotate;
  }

  /// 获取轮转后的文件名
  ///
  /// 根据当前日志文件的路径和轮转索引生成轮转后的日志文件名。
  ///
  /// 参数:
  /// - [originalFile] 原始日志文件。
  /// - [rotationIndex] 轮转索引。
  ///
  /// 返回:
  /// - 返回生成的轮转文件名，格式为：`原始文件名.轮转索引`。
  @override
  String getRotatedFileName(File originalFile, int rotationIndex) {
    final dir = originalFile.parent;
    final baseFileName = path.basenameWithoutExtension(originalFile.path);
    final extension = path.extension(originalFile.path);

    // 如果是每日轮转，添加日期后缀
    if (_lastCheckDate != null) {
      final dateStr = DateFormat('yyyyMMdd').format(_lastCheckDate!);
      return path.join(
          dir.path, '$baseFileName.$dateStr.$rotationIndex$extension');
    }

    return path.join(dir.path, '$baseFileName.$rotationIndex$extension');
  }

  /// 清理过期的日志文件
  ///
  /// 根据日志目录和日志文件的匹配模式，清理旧的日志文件。会删除超过最大备份数量的日志文件。
  ///
  /// 参数:
  /// - [directory] 日志文件所在目录。
  /// - [pattern] 匹配的日志文件模式，通常为日志文件的基础名称。
  ///
  /// 返回:
  /// - 无返回值。该方法将删除超过备份数量限制的旧日志文件。
  @override
  Future<void> cleanupOldLogs(Directory directory, String pattern) async {
    try {
      final baseFileName = path.basename(pattern);
      final files = await _findRotatedFiles(directory, baseFileName);

      // 如果文件数量未超过最大备份数，无需清理
      if (files.length <= maxBackups) {
        return;
      }

      // 按轮转索引排序（降序）
      files
          .sort((a, b) => _getRotationIndex(b).compareTo(_getRotationIndex(a)));

      // 删除超出最大备份数量的旧文件
      for (var i = maxBackups; i < files.length; i++) {
        final file = files[i];
        try {
          await file.delete();
        } catch (e) {
          print('Failed to delete old log file ${file.path}: $e');
          // 继续处理其他文件，不中断清理过程
        }
      }
    } catch (e) {
      print('Error during log cleanup: $e');
      // 清理过程中的错误不应影响主要的日志功能
    }
  }

  /// 查找所有轮转的日志文件
  ///
  /// 根据给定的日志文件名模式，查找日志目录中所有符合轮转规则的日志文件。
  ///
  /// 参数:
  /// - [directory] 日志文件所在目录。
  /// - [baseFileName] 日志文件的基础名称，通常是原始日志文件的名称。
  ///
  /// 返回:
  /// - 返回一个包含所有轮转日志文件的列表。
  Future<List<File>> _findRotatedFiles(
      Directory directory, String baseFileName) async {
    final List<File> rotatedFiles = [];

    try {
      await for (final entity in directory.list()) {
        if (entity is! File) continue;

        final fileName = path.basename(entity.path);
        if (!_isRotatedLogFile(fileName, baseFileName)) continue;

        rotatedFiles.add(entity);
      }
    } catch (e) {
      print('Error while listing directory: $e');
    }

    return rotatedFiles;
  }

  /// 检查文件是否是轮转的日志文件
  ///
  /// 判断给定的文件名是否符合轮转后的日志文件命名规则。
  ///
  /// 参数:
  /// - [fileName] 文件名。
  /// - [baseFileName] 日志文件的基础名称。
  ///
  /// 返回:
  /// - 如果文件名符合轮转日志文件的规则（例如 `logfile.1`），返回 `true`；否则返回 `false`。
  bool _isRotatedLogFile(String fileName, String baseFileName) {
    // 检查文件名是否符合 "baseFileName.数字" 的格式
    final regex = RegExp('^$baseFileName\\.(\\d+)\$');
    return regex.hasMatch(fileName);
  }

  /// 获取文件的轮转索引
  ///
  /// 从文件名中提取出轮转的索引值。
  ///
  /// 参数:
  /// - [file] 需要提取轮转索引的文件。
  ///
  /// 返回:
  /// - 如果文件名符合轮转规则，返回轮转的索引（整数）。如果无法解析索引，返回 -1。
  int _getRotationIndex(File file) {
    final fileName = path.basename(file.path);
    final parts = fileName.split('.');
    if (parts.length < 2) return -1;

    try {
      return int.parse(parts.last);
    } catch (e) {
      return -1;
    }
  }
}
