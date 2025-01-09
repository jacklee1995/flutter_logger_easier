import 'dart:io' show File;

import 'package:archive/archive.dart' show GZipDecoder, GZipEncoder;

import '../interfaces/compression_handler.dart';

/// Gzip压缩处理器
///
/// 实现了 [CompressionHandler] 接口，用于对日志文件进行 Gzip 压缩和解压缩处理。
///
/// 用途:
/// - 在日志轮转过程中压缩日志文件以节省存储空间。
/// - 提供解压缩功能以便于日志查看和分析。
class GzipCompressionHandler implements CompressionHandler {
  final void Function(String message)? onProgress;

  GzipCompressionHandler({this.onProgress});

  @override
  Future<void> compress(File sourceFile, File targetFile) async {
    try {
      onProgress?.call('Starting compression of ${sourceFile.path}');

      final input = await sourceFile.readAsBytes();
      final gzipData = GZipEncoder().encode(input);

      await targetFile.writeAsBytes(gzipData);

      onProgress?.call('Compression completed: ${targetFile.path}');
    } catch (e) {
      onProgress?.call('Compression failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> decompress(File sourceFile, File targetFile) async {
    try {
      onProgress?.call('Starting decompression of ${sourceFile.path}');

      final input = await sourceFile.readAsBytes();
      final decompressed = GZipDecoder().decodeBytes(input);

      await targetFile.writeAsBytes(decompressed);

      onProgress?.call('Decompression completed: ${targetFile.path}');
    } catch (e) {
      onProgress?.call('Decompression failed: $e');
      rethrow;
    }
  }

  @override
  String get compressedExtension => '.gz';
}
