import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'app/logger.dart';

void main() {
  // 设置错误处理为致命错误
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // 可以在这里添加额外的错误上报逻辑
  };

  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    initializeLogger().then((initializedLogger) {
      logger = initializedLogger;
      logger.trace('The logger is ready.');
      logger.debug('The logger is ready.');
      logger.info('The logger is ready.');
      logger.warn('The logger is ready.');
      logger.error('The logger is ready.');
      logger.critical('The logger is ready.');
      logger.fatal('The logger is ready.');

      runApp(const LoggerDemoApp());
    }).catchError((error, stackTrace) {
      debugPrint('Logger initialization failed: $error');
      runApp(const LoggerDemoApp());
    });
  }, (error, stackTrace) {
    // 全局错误处理
    debugPrint('Unhandled error: $error\nStacktrace: $stackTrace');
  });
}

class LoggerDemoApp extends StatelessWidget {
  const LoggerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logger Demo',
      home: LoggerDemoPage(),
    );
  }
}

class LoggerDemoPage extends StatefulWidget {
  const LoggerDemoPage({super.key});

  @override
  State<LoggerDemoPage> createState() => _LoggerDemoPageState();
}

class _LoggerDemoPageState extends State<LoggerDemoPage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
  }

  void _performRiskyOperation() {
    try {
      // 模拟可能出错的操作
      final result = _divideNumbers(10, 0);
      logger.info('Division result: $result');
    } catch (e, stackTrace) {
      // 捕获并记录错误
      logger.error('Division error occurred', error: e, stackTrace: stackTrace);

      // 显示错误消息
      _showErrorSnackBar(e.toString());
    }
  }

  int _divideNumbers(int a, int b) {
    if (b == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return a ~/ b;
  }

  void _measurePerformance() async {
    // 使用性能度量
    final result =
        await logger.measurePerformance('complex_calculation', () async {
      return await _complexCalculation();
    });

    logger.info('Complex calculation result: $result');
  }

  Future<int> _complexCalculation() async {
    // 模拟耗时计算
    await Future.delayed(Duration(seconds: 2));
    return Random().nextInt(1000);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      logger.debug('Counter incremented to $_counter');

      // 随机触发一些日志场景
      if (_counter % 5 == 0) {
        _performRiskyOperation();
      }

      if (_counter % 7 == 0) {
        _measurePerformance();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logger Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              // 记录并显示性能指标
              logger.logPerformanceMetrics();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Counter Value:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _performRiskyOperation,
              child: Text('Perform Risky Operation'),
            ),
            ElevatedButton(
              onPressed: _measurePerformance,
              child: Text('Measure Performance'),
            ),
            // 新增日志级别触发按钮
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    logger.debug(
                        'Debug button pressed - Detailed diagnostic information');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Log Debug'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger
                        .info('Info button pressed - General application flow');
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('Log Info'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.warn(
                        'Warning button pressed - Potential issue or unexpected behavior');
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text('Log Warning'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.error(
                      'Error button pressed - More serious problem',
                      error: Exception('Sample error occurred'),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Log Error'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.critical(
                        'Critical button pressed - Critical failure',
                        error: Exception('Critical system failure'));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple),
                  child: Text('Log Critical'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.fatal(
                        'Fatal button pressed - Unrecoverable system error',
                        error: Exception('Fatal system crash'));
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text('Log Fatal'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    // 记录页面销毁
    logger.debug('LoggerDemoPage disposed');
    super.dispose();
  }
}

// 自定义异常示例
class CustomBusinessException implements Exception {
  final String message;
  final int errorCode;

  CustomBusinessException(this.message, this.errorCode);

  @override
  String toString() {
    return 'BusinessException: $message (Code: $errorCode)';
  }
}

// 网络请求模拟
class NetworkService {
  Future<String> fetchData() async {
    try {
      // 模拟网络请求
      await Future.delayed(Duration(seconds: 2));

      // 随机抛出异常
      if (Random().nextBool()) {
        throw CustomBusinessException('Network Error', 500);
      }

      return 'Successful data fetch';
    } catch (e, stackTrace) {
      // 记录网络请求错误
      logger.error('Network request failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
