import 'dart:io' show File;
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
  final bool delayCompress;

  DateTime _lastRotateTime = DateTime.now();
  int _currentSize = 0;

  LogRotateManager({
    required this.strategy,
    this.compressionHandler,
    this.delayCompress = true,
  });

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
    _currentSize = await logFile.length();

    if (strategy.shouldRotate(logFile, _currentSize, _lastRotateTime)) {
      await _rotateLog(logFile);
      _lastRotateTime = DateTime.now();
      _currentSize = 0;
    }
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
  Future<void> _rotateLog(File logFile) async {
    try {
      // 1. 获取轮转后的文件名
      final rotatedFileName = strategy.getRotatedFileName(
        logFile,
        _getNextRotationIndex(logFile),
      );
      final rotatedFile = File(rotatedFileName);

      // 2. 如果目标文件已存在，先删除
      if (await rotatedFile.exists()) {
        await rotatedFile.delete();
      }

      // 3. 重命名当前日志文件
      await logFile.rename(rotatedFileName);

      // 4. 如果需要压缩且不是延迟压缩
      if (compressionHandler != null && !delayCompress) {
        await _compressLog(rotatedFile);
      }

      // 5. 清理旧日志文件
      await strategy.cleanupOldLogs(
        logFile.parent,
        path.basename(logFile.path),
      );
    } catch (e) {
      print('Error during log rotation: $e');
      // 轮转失败不应该影响正常的日志记录
    }
  }

  /// 获取下一个轮转索引
  ///
  /// 根据当前日志文件的文件名，获取日志轮转的下一个索引。若当前目录下没有同名文件，则返回 1；否则返回现有文件数 + 1。
  ///
  /// 参数:
  /// - [logFile] 当前的日志文件。
  ///
  /// 返回:
  /// - 下一个轮转文件的索引（整数）。
  int _getNextRotationIndex(File logFile) {
    try {
      final directory = logFile.parent;
      final baseFileName = path.basename(logFile.path);
      final files = directory
          .listSync()
          .whereType<File>()
          .where((f) => path.basename(f.path).startsWith(baseFileName))
          .toList();

      if (files.isEmpty) return 1;

      return files.length + 1;
    } catch (e) {
      print('Error getting next rotation index: $e');
      return 1;
    }
  }

  /// 压缩日志文件
  ///
  /// 如果配置了压缩处理器，并且轮转后文件需要压缩，则执行日志文件的压缩操作。压缩后会删除原始日志文件。
  ///
  /// 参数:
  /// - [logFile] 需要压缩的日志文件。
  ///
  /// 返回:
  /// - 无返回值。压缩成功后，原始文件将被删除。
  Future<void> _compressLog(File logFile) async {
    if (compressionHandler == null) return;

    final compressedFile =
        File('${logFile.path}${compressionHandler!.compressedExtension}');
    await compressionHandler!.compress(logFile, compressedFile);
    await logFile.delete();
  }
}
