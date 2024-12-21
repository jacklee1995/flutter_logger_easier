import 'dart:async';
import 'dart:isolate';

import '../core/log_level.dart';
import '../core/logger_easier_base.dart';
import 'crash_analytics.dart';

class ErrorReporter {
  final Logger _logger;
  late final CrashAnalytics _crashAnalytics;
  bool _isInitialized = false;

  ErrorReporter({Logger? logger})
      : _logger = logger ?? Logger(middlewares: []) {
    _crashAnalytics = CrashAnalytics(_logger);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 设置全局错误处理
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await _handleError(
          errorAndStacktrace[0], errorAndStacktrace[1] as StackTrace?);
    }).sendPort);

    // 设置 Zone 错误处理
    runZonedGuarded(() {
      // 应用的主要逻辑应该在这里运行
    }, (error, stackTrace) async {
      await _handleError(error, stackTrace);
    });

    await _crashAnalytics.initialize();
    _isInitialized = true;
  }

  Future<void> _handleError(dynamic error, StackTrace? stackTrace) async {
    try {
      // 记录错误日志
      _logger.log(LogLevel.error, 'Uncaught error',
          error: error, stackTrace: stackTrace);

      // 分析错误
      final analysisResult = await _crashAnalytics.analyzeError(
          error, stackTrace ?? StackTrace.empty);

      // 上报错误
      await _reportError(error, stackTrace, analysisResult);
    } catch (e, s) {
      // 如果在错误处理过程中出现异常，记录这个新的异常
      _logger.log(LogLevel.error, 'Error in error handling',
          error: e, stackTrace: s);
    }
  }

  // TODO:
  Future<void> _reportError(dynamic error, StackTrace? stackTrace,
      Map<String, dynamic> analysisResult) async {
    // 这里可以实现将错误上报到远程服务器的逻辑
    // 例如，使用 HTTP 请求发送错误信息到错误跟踪服务
    // 为了示例，我们只是将错误信息打印出来
    print('Reporting error:');
    print('Error: $error');
    print('StackTrace: ${stackTrace ?? "No stack trace available"}');
    print('Analysis Result: $analysisResult');
  }

  Future<void> reportError(dynamic error, StackTrace? stackTrace) async {
    await _handleError(error, stackTrace);
  }

  Future<void> close() async {
    await _crashAnalytics.close();
  }
}
