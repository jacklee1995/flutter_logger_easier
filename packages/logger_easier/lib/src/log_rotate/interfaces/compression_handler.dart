import 'dart:io' show File;

/// 日志压缩处理接口
///
/// 提供日志文件的压缩和解压缩功能，以及压缩文件扩展名。
/// 实现此接口可以自定义压缩逻辑，例如使用不同的压缩算法。
abstract class CompressionHandler {
  /// 压缩日志文件
  ///
  /// [sourceFile] 源文件
  /// [targetFile] 目标文件
  Future<void> compress(File sourceFile, File targetFile);

  /// 解压日志文件
  ///
  /// [sourceFile] 源文件
  /// [targetFile] 目标文件
  Future<void> decompress(File sourceFile, File targetFile);

  /// 获取压缩文件扩展名
  String get compressedExtension;
}
