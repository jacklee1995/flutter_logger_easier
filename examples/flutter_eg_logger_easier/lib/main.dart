import 'dart:async';
import 'package:flutter/material.dart';
import 'app/log_helper.dart';
import 'ui/home_page.dart';
import 'app/size_based_logger.dart';
// import 'app/time_based_logger.dart';  // 预留基于时间的配置

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 初始化基于大小的日志系统
    await SizeBasedLoggerConfig.instance.initialize();
    // 如果需要使用基于时间的日志系统，注释上面的行，取消注释下面的行
    // await TimeBasedLoggerConfig.instance.initialize();

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
    if (SizeBasedLoggerConfig.instance.isInitialized) {
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
