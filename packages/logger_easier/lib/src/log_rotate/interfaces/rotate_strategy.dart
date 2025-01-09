import 'dart:io' show Directory, File;

/// 日志轮转策略接口
///
/// 定义了日志轮转的核心行为：
/// - 判断是否需要进行日志轮转。
/// - 生成轮转后文件的名称。
/// - 清理过期日志文件。
///
/// 不同实现可以支持基于文件大小、时间等条件的轮转策略。
abstract class RotateStrategy {
  /// 检查是否需要进行日志轮转
  ///
  /// [logFile] 当前日志文件
  /// [currentSize] 当前日志文件大小
  /// [lastRotateTime] 上次轮转时间
  /// 返回true表示需要进行轮转
  bool shouldRotate(File logFile, int currentSize, DateTime lastRotateTime);

  /// 获取轮转后的文件名
  ///
  /// [originalFile] 原始日志文件
  /// [rotateIndex] 轮转索引
  String getRotatedFileName(File originalFile, int rotateIndex);

  /// 清理过期的日志文件
  ///
  /// [directory] 日志目录
  /// [pattern] 日志文件匹配模式
  Future<void> cleanupOldLogs(Directory directory, String pattern);
}
