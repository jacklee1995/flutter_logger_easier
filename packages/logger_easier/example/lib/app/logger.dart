// app/logger.dart
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';
import 'package:logger_easier/logger_easier.dart';

// 获取日志目录路径
Future<String> getLogDirectory() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  return path.join(appDocDir.path, 'logs');
}

// 创建基于时间的日志中间件
Future<FileMiddleware> createTimeBasedMiddleware() async {
  final logDirectory = await getLogDirectory();
  return FileMiddleware.createTimeBasedMiddleware(
    logDirectory: logDirectory,
    baseFileName: 'app.log',
    rotateInterval: Duration(days: 1),
    maxBackups: 7,
    compress: true,
  );
}

// 创建基于大小的日志中间件
Future<FileMiddleware> createSizeBasedMiddleware() async {
  final logDirectory = await getLogDirectory();
  return FileMiddleware.createSizeBasedMiddleware(
    logDirectory: logDirectory,
    baseFileName: 'app.log',
    maxSize: 10 * 1024 * 1024, // 10MB
    maxBackups: 5,
    compress: true,
  );
}

// 创建自定义配置的中间件
Future<FileMiddleware> createCustomMiddleware() async {
  final logDirectory = await getLogDirectory();
  return FileMiddleware(
    logDirectory: logDirectory,
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
}

Future<Logger> initializeLogger() async {
  final logDirectory = await getLogDirectory();
  debugPrint('Log directory: $logDirectory');

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

  // 创建中间件
  final timeBasedMiddleware = await createTimeBasedMiddleware();

  final logger = Logger(
    minLevel: LogLevel.trace,
    outputFunction: debugPrint,
  );

  // 添加中间件
  logger.use(timeBasedMiddleware);
  // 或者使用基于大小的中间件
  // logger.use(sizeBasedMiddleware);

  return logger;
}

// 全局变量，但是需要异步初始化
late Logger logger;
