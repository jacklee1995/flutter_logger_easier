import 'dart:io' show Directory, File;
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart' show DateFormat;

import '../interfaces/rotate_strategy.dart' show RotateStrategy;

/// 基于时间的日志轮转策略
///
/// 当日志文件的最后轮转时间与当前时间的间隔超过指定周期时触发轮转。
/// 支持以日期格式生成轮转后的文件名，并限制备份的最大数量。
///
/// 参数:
/// - [rotateInterval] 轮转时间间隔，默认值为1天。
/// - [maxBackups] 最大备份数量，默认值为7。
/// - [dateFormat] 日期格式，用于生成轮转文件名，默认值为 'yyyyMMdd'。
class TimeBasedStrategy implements RotateStrategy {
  final Duration rotateInterval;
  final int maxBackups;
  final String dateFormat;
  late final DateFormat _formatter;

  TimeBasedStrategy({
    this.rotateInterval = const Duration(days: 1),
    this.maxBackups = 7,
    this.dateFormat = 'yyyyMMdd',
  }) {
    _formatter = DateFormat(dateFormat);
  }

  @override
  bool shouldRotate(File logFile, int currentSize, DateTime lastRotateTime) {
    final now = DateTime.now();
    return now.difference(lastRotateTime) >= rotateInterval;
  }

  @override
  String getRotatedFileName(File originalFile, int rotateIndex) {
    final date = DateTime.now().subtract(Duration(days: rotateIndex - 1));
    return '${originalFile.path}.${_formatter.format(date)}';
  }

  @override
  Future<void> cleanupOldLogs(Directory directory, String pattern) async {
    try {
      final baseFileName = path.basename(pattern);
      final files = await _findRotatedFiles(directory, baseFileName);

      // 如果文件数量未超过最大备份数，无需清理
      if (files.length <= maxBackups) {
        return;
      }

      // 按日期排序（降序）
      files.sort((a, b) {
        final dateA = _extractDateFromFileName(a);
        final dateB = _extractDateFromFileName(b);
        return dateB.compareTo(dateA);
      });

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
  bool _isRotatedLogFile(String fileName, String baseFileName) {
    // 使用更精确的日期格式匹配
    final datePattern = _getDatePatternFromFormat();
    final pattern = RegExp('^$baseFileName\\.($datePattern)\$');
    return pattern.hasMatch(fileName);
  }

  /// 从文件名中提取日期
  DateTime _extractDateFromFileName(File file) {
    try {
      final fileName = path.basename(file.path);
      final datePart = fileName.split('.').last;
      return _formatter.parse(datePart);
    } catch (e) {
      // 如果解析失败，返回一个很早的日期，确保文件排在最后
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  /// 获取日期字符串的正则表达式模式
  String _getDatePatternFromFormat() {
    final Map<String, String> patterns = {
      'yyyy': '\\d{4}',
      'MM': '(0[1-9]|1[0-2])',
      'dd': '(0[1-9]|[12]\\d|3[01])',
      'HH': '([01]\\d|2[0-3])',
      'mm': '[0-5]\\d',
      'ss': '[0-5]\\d',
    };

    String result = dateFormat;
    patterns.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }
}
