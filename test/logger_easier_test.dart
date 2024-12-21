import 'package:logger_easier/logger_easier.dart';
import 'package:logger_easier/src/core/log_record.dart';
import 'package:logger_easier/src/error_reporting/error_reporter.dart';
import 'package:logger_easier/src/performance/performance_monitor.dart';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'logger_easier_test.mocks.dart';

// 生成 Mock 类
@GenerateMocks([
  PerformanceMonitor,
  ErrorReporter,
  LogMiddleware,
  BasePrinter,
  LogFormatter,
  LogFilter
])
void main() {
  group('Logger', () {
    late Logger logger;
    late MockPerformanceMonitor mockPerformanceMonitor;
    late MockErrorReporter mockErrorReporter;
    late MockLogMiddleware mockLogMiddleware;

    setUp(() {
      // 重置单例
      Logger.reset();

      // 创建 Mock 对象
      mockPerformanceMonitor = MockPerformanceMonitor();
      mockErrorReporter = MockErrorReporter();
      mockLogMiddleware = MockLogMiddleware();

      // 初始化 Logger
      logger = Logger(
        performanceMonitor: mockPerformanceMonitor,
        errorReporter: mockErrorReporter,
        middlewares: [mockLogMiddleware],
      );
    });

    test('Logger singleton behavior', () {
      final logger1 = Logger();
      final logger2 = Logger();
      expect(logger1, same(logger2));
    });

    test('Log methods call log with correct log level', () {
      // Debug 日志
      logger.debug('Debug message');
      verify(mockLogMiddleware.handle(argThat(
        isA<LogRecord>().having((r) => r.level, 'level', LogLevel.debug),
      ))).called(1);

      // Info 日志
      logger.info('Info message');
      verify(mockLogMiddleware.handle(argThat(
        isA<LogRecord>().having((r) => r.level, 'level', LogLevel.info),
      ))).called(1);

      // Warning 日志
      logger.warn('Warning message');
      verify(mockLogMiddleware.handle(argThat(
        isA<LogRecord>().having((r) => r.level, 'level', LogLevel.warn),
      ))).called(1);
    });

    test('Error and critical logs trigger error reporting', () {
      final testError = Exception('Test error');
      final testStackTrace = StackTrace.current;

      // Error 日志
      logger.error('Error message',
          error: testError, stackTrace: testStackTrace);
      verify(mockErrorReporter.reportError(testError, testStackTrace))
          .called(1);

      // Critical 日志
      logger.critical('Critical message',
          error: testError, stackTrace: testStackTrace);
      verify(mockErrorReporter.reportError(testError, testStackTrace))
          .called(1);
    });

    test('Performance measurement works', () async {
      when(mockPerformanceMonitor.recordMetric(any, any)).thenAnswer((_) {});

      // 异步性能度量
      final asyncResult =
          await logger.measurePerformance('test_async', () async {
        await Future.delayed(Duration(milliseconds: 100));
        return 42;
      });
      expect(asyncResult, 42);
      verify(mockPerformanceMonitor.recordMetric(
              argThat(equals('test_async')), argThat(isA<num>())))
          .called(1);

      // 同步性能度量
      final syncResult = logger.measureSyncPerformance('test_sync', () {
        return 24;
      });
      expect(syncResult, 24);
      verify(mockPerformanceMonitor.recordMetric(
              argThat(equals('test_sync')), argThat(isA<num>())))
          .called(1);
    });

    test('Performance metrics logging', () {
      final testMetrics = {
        'operation1': 100.0,
        'operation2': 200.0,
      };

      // 打印详细的调试信息
      print('Test: Creating mock performance monitor');
      when(mockPerformanceMonitor.getMetrics()).thenReturn(testMetrics);

      // 捕获日志的列表
      final logEntries = <String>[];

      // 创建 Logger，使用现有的 mockLogMiddleware
      logger = Logger(
        performanceMonitor: mockPerformanceMonitor,
        middlewares: [mockLogMiddleware],
      );

      // 拦截 info 方法的调用
      when(mockLogMiddleware.handle(any)).thenAnswer((invocation) {
        final record = invocation.positionalArguments[0] as LogRecord;
        print('Intercepted log: ${record.message}, level: ${record.level}');
        if (record.level == LogLevel.info) {
          logEntries.add(record.message);
        }
        return Future.value();
      });

      // 调用性能指标日志记录方法
      print('Test: Calling logPerformanceMetrics');
      logger.logPerformanceMetrics();

      print('Test: Log entries: $logEntries');

      // 验证日志条目
      expect(logEntries, [
        'Performance: operation1 - 100.0ms',
        'Performance: operation2 - 200.0ms',
      ]);
    });

    test('Close method calls close on all components', () async {
      await logger.close();

      verify(mockLogMiddleware.close()).called(1);
      verify(mockPerformanceMonitor.close()).called(1);
      verify(mockErrorReporter.close()).called(1);
    });

    test('Add and remove handlers', () {
      final additionalHandler = MockLogMiddleware();

      logger.addHandler(additionalHandler);
      logger.log(LogLevel.info, 'Test message');

      verify(additionalHandler.handle(argThat(isA<LogRecord>()))).called(1);

      logger.removeHandler(additionalHandler);
      logger.log(LogLevel.info, 'Another test message');

      verifyNever(additionalHandler.handle(argThat(isA<LogRecord>())));
    });
  });
}
