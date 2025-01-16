import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';
import 'package:logger_easier/logger_easier.dart';
import 'package:json_middleware_for_logger_easier/json_middleware_for_logger_easier.dart';

Future<Logger> initializeLogger() async {
  // 获取应用文档目录
  final appDocDir = await getApplicationDocumentsDirectory();
  final logDirectory = path.join(appDocDir.path, 'logs');

  // 确保日志目录存在
  final directory = Directory(logDirectory);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  // 创建一个没有默认中间件的 Logger 实例
  final logger = Logger(
    minLevel: LogLevel.trace,
    outputFunction: debugPrint,
    logDirectory: logDirectory,
    baseFileName: 'app.log',
  );

  // 只添加 JSON 中间件
  logger.use(JsonPrintMiddleware(
    config: JsonFormatterConfig(
      includeError: true,
      includeStackTrace: true,
      includeSeparator: true,
    ),
    outputFunction: debugPrint,
  ));

  // 添加文件中间件（如果需要的话）
  // logger.use(FileMiddleware(
  //   logDirectory: logDirectory,
  //   baseFileName: 'app.log',
  //   maxFileSize: 10 * 1024 * 1024, // 10MB
  //   maxBackupIndex: 5,
  //   compress: true,
  // ));

  return logger;
}

// 全局变量
late Logger logger;
