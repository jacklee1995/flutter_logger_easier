import 'dart:async';
import 'package:flutter/material.dart';
import 'app/logger_config.dart';
import 'app/log_helper.dart';
import 'ui/home_page.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 初始化日志系统
    await LoggerConfig.instance.initialize();

    // 配置Flutter错误处理
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      Log.error('Flutter error',
          error: details.exception, stackTrace: details.stack);
    };

    Log.info('Application starting...');

    runApp(const LoggerDemoApp());
  }, (error, stack) {
    // 在日志系统初始化之前发生的错误，直接打印到控制台
    if (LoggerConfig.instance.isInitialized) {
      Log.critical('Uncaught error', error: error, stackTrace: stack);
    } else {
      print('Error before logger initialization: $error\n$stack');
    }
  });
}

class LoggerDemoApp extends StatelessWidget {
  const LoggerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logger Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
