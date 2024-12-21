// app/logger.dart
import 'dart:io';
import 'package:flutter/material.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';
import 'package:logger_easier/logger_easier.dart';

Future<Logger> initializeLogger() async {
  // 获取应用文档目录
  final appDocDir = await getApplicationDocumentsDirectory();
  final logDirectory = '${appDocDir.path}/logs';

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
    final testFile = File('$logDirectory/test.txt');
    await testFile.writeAsString('permission test');
    await testFile.delete();
    debugPrint('Log directory is writable');
  } catch (e) {
    debugPrint('Cannot write to log directory: $e');
  }

  return Logger(
    minLevel: LogLevel.trace,
    outputFunction: debugPrint,
    logDirectory: logDirectory,
    baseFileName: 'app.log',
    maxFileSize: 10 * 1024 * 1024, // 10MB
    maxBackupIndex: 5,
    compress: true,
  );
}

// 全局变量，但是需要异步初始化
late Logger logger;
