// app/logger.dart
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';
import 'package:logger_easier/logger_easier.dart';

final timeBasedMiddleware = FileMiddleware.createTimeBasedMiddleware(
  logDirectory: '/path/to/logs',
  baseFileName: 'app.log',
  rotateInterval: Duration(days: 1),
  maxBackups: 7,
  compress: true,
);

// 基于大小的日志中间件
final sizeBasedMiddleware = FileMiddleware.createSizeBasedMiddleware(
  logDirectory: '/path/to/logs',
  baseFileName: 'app.log',
  maxSize: 10 * 1024 * 1024, // 10MB
  maxBackups: 5,
  compress: true,
);

// 使用自定义配置
final customMiddleware = FileMiddleware(
  logDirectory: '/path/to/logs',
  baseFileName: 'app.log',
  rotateConfig: LogRotateConfig(
    strategy: TimeBasedStrategy(
      rotateInterval: Duration(hours: 12),
      maxBackups: 10,
    ),
    compressionHandler: GzipCompressionHandler(),
    enableStorageMonitoring: true,
    minimumFreeSpace: 200 * 1024 * 1024, // 200MB
  ),
);

Future<Logger> initializeLogger() async {
  // 获取应用文档目录
  final appDocDir = await getApplicationDocumentsDirectory();
  final logDirectory = path.join(appDocDir.path, 'logs');

  debugPrint('appDocDir: $appDocDir');
  debugPrint('logDirectory: $logDirectory');

  // 确保日志目录存在
  final directory = Directory(logDirectory);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
    debugPrint('Created log directory: $logDirectory');
  }

  // 测试目录是否可写
  try {
    final testFile = File(path.join(logDirectory, 'test.txt'));
    await testFile.writeAsString('permission test');
    await testFile.delete();
    debugPrint('Log directory is writable');
  } catch (e, s) {
    debugPrint('Cannot write to log directory: $e\n$s');
  }

  return Logger(
    minLevel: LogLevel.trace,
    outputFunction: debugPrint,
    logDirectory: logDirectory,
    baseFileName: 'app.log',
  );
}

// 全局变量，但是需要异步初始化
late Logger logger;
