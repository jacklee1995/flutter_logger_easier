import 'dart:async' show TimeoutException, Timer;
import 'dart:developer' as developer;
import 'package:vm_service/vm_service.dart' as vm_service;
import 'package:vm_service/vm_service_io.dart' show vmServiceConnectUri;
import 'dart:math' show max, min;

import 'performance_metrics.dart';

/// 性能监控类,用于收集和分析应用程序的性能指标
class PerformanceMonitor {
  /// 用于记录信息的回调函数
  final _infoLogger;

  /// 用于记录错误的回调函数
  final _errorLogger;

  /// 性能指标存储
  final PerformanceMetrics _metrics = PerformanceMetrics();

  /// 定期报告的计时器
  Timer? _reportingTimer;

  /// VM服务实例
  vm_service.VmService? _vmService;

  /// 是否启用 VM Service 监控
  final bool enableVmServiceMonitoring;

  /// 构造函数
  ///
  /// [infoLogger] 可选的信息日志记录回调
  /// [errorLogger] 可选的错误日志记录回调
  /// [enableVmServiceMonitoring] 是否启用 VM Service 监控
  PerformanceMonitor(
      {infoLogger, errorLogger, this.enableVmServiceMonitoring = false})
      : _infoLogger = infoLogger,
        _errorLogger = errorLogger;

  /// 初始化性能监控
  Future<void> initialize() async {
    // 仅在启用监控时尝试连接
    if (enableVmServiceMonitoring) {
      try {
        await _connectToVmService();
      } catch (e) {
        _infoLogger?.call('VM Service monitoring is disabled or unavailable');
      }
    }

    // 无论是否连接成功都启动定期报告
    _startReportingTimer();
  }

  /// 连接到 VM Service
  Future<void> _connectToVmService() async {
    try {
      final serviceInfo = await developer.Service.getInfo();
      if (serviceInfo.serverUri != null) {
        final serverUri = serviceInfo.serverUri!;

        // 尝试多种连接方式，并添加超时
        final uriVariants = [
          serverUri.toString().replaceFirst('http', 'ws'),
          serverUri.toString().replaceFirst('http', 'wss'),
        ];

        for (final uri in uriVariants) {
          try {
            _vmService = await vmServiceConnectUri(uri)
                .timeout(const Duration(seconds: 3));

            _infoLogger?.call('Connected to VM Service at $uri');
            return;
          } on TimeoutException {
            _infoLogger?.call('Connection to $uri timed out');
          } catch (connectError) {
            _infoLogger?.call(
                'Failed to connect with URI: $uri. Error: $connectError');
          }
        }

        // 如果所有尝试都失败
        throw Exception('VM Service connection failed');
      } else {
        throw Exception('VM Service URI is not available');
      }
    } catch (e) {
      _errorLogger?.call('VM Service connection error', error: e);
      rethrow;
    }
  }

  /// 开始定期报告性能指标
  void _startReportingTimer() {
    _reportingTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      try {
        reportMetrics();
      } catch (e) {
        _errorLogger?.call('Error during periodic metrics reporting', error: e);
      }
    });
  }

  /// 获取所有性能指标
  Map<String, num> getMetrics() {
    return _metrics.getAllMetrics();
  }

  /// 报告当前的性能指标
  void reportMetrics() {
    final metrics = _metrics.getAllMetrics();

    // 如果没有指标，不记录日志
    if (metrics.isEmpty) return;

    // 格式化输出更详细的性能指标信息
    final formattedMetrics = metrics.entries.map((entry) {
      return '${entry.key}: ${entry.value}';
    }).join(', ');

    _infoLogger?.call('Performance Metrics: $formattedMetrics');
  }

  /// 记录应用启动性能
  void recordStartupPerformance(Duration startupTime) {
    _metrics.setMetric('app_startup_time', startupTime.inMilliseconds);
  }

  /// 记录网络请求性能
  void recordNetworkRequestPerformance(String endpoint, int responseTime) {
    _metrics.setMetric('network_request_${endpoint}_time', responseTime);
  }

  /// 记录数据库操作性能
  void recordDatabaseOperationPerformance(String operation, int executionTime) {
    _metrics.setMetric('database_${operation}_time', executionTime);
  }

  /// 记录渲染性能
  void recordRenderPerformance(String widgetName, int renderTime) {
    _metrics.setMetric('render_${widgetName}_time', renderTime);
  }

  /// 记录一个自定义指标
  void recordMetric(String name, num value) {
    _metrics.setMetric(name, value);
  }

  /// 开始计时一个操作
  void startTimer(String operationName) {
    _metrics.startTimer(operationName);
  }

  /// 停止计时一个操作并记录耗时
  void stopTimer(String operationName) {
    _metrics.stopTimer(operationName);
  }

  /// 记录一个事件的发生
  void recordEvent(String eventName) {
    _metrics.incrementMetric(eventName);
  }

  /// 收集内存使用情况
  Future<void> collectMemoryMetrics() async {
    if (!enableVmServiceMonitoring || _vmService == null) return;

    try {
      final isolateId = await _getIsolateId();
      if (isolateId != null) {
        final memoryUsage = await _vmService!.getMemoryUsage(isolateId);
        _metrics.setMetric('heapUsage', memoryUsage.heapUsage?.toDouble() ?? 0);
        _metrics.setMetric(
            'externalUsage', memoryUsage.externalUsage?.toDouble() ?? 0);
      }
    } catch (e) {
      _errorLogger?.call('Failed to collect memory metrics', error: e);
    }
  }

  /// 收集CPU使用情况
  Future<void> collectCpuMetrics() async {
    if (!enableVmServiceMonitoring || _vmService == null) return;

    try {
      final isolateId = await _getIsolateId();
      if (isolateId != null) {
        final now = DateTime.now().microsecondsSinceEpoch;
        final timeOriginMicros = now - 1000000; // 1秒前
        const timeExtentMicros = 1000000; // 1秒的时间范围

        final cpuSamples = await _vmService!.getCpuSamples(
          isolateId,
          timeOriginMicros,
          timeExtentMicros,
        );
        _metrics.setMetric(
            'cpuSampleCount', cpuSamples.samples?.length.toDouble() ?? 0);

        if (cpuSamples.samples != null && cpuSamples.samples!.isNotEmpty) {
          final cpuUsages =
              cpuSamples.samples!.map((sample) => sample.tid ?? 0).toList();
          final totalCpu = cpuUsages.fold<int>(0, (sum, tid) => sum + tid);

          _metrics.setMetric('averageCpuUsage', totalCpu / cpuUsages.length);
          _metrics.setMetric('maxCpuUsage', cpuUsages.reduce(max).toDouble());
          _metrics.setMetric('minCpuUsage', cpuUsages.reduce(min).toDouble());

          final vmCpu = cpuSamples.samples!
              .where((sample) => sample.vmTag == 'VM')
              .length;
          _metrics.setMetric('vmCpuUsage', vmCpu / cpuSamples.samples!.length);
        }
      }
    } catch (e) {
      _errorLogger?.call('Failed to collect CPU samples', error: e);
    }
  }

  /// 获取当前Isolate的ID
  Future<String?> _getIsolateId() async {
    if (!enableVmServiceMonitoring || _vmService == null) return null;

    try {
      final vm = await _vmService!.getVM();
      return vm.isolates?.firstOrNull?.id;
    } catch (e) {
      _errorLogger?.call('Failed to get isolate ID', error: e);
      return null;
    }
  }

  /// 分析性能瓶颈
  void analyzePerformanceBottlenecks() {
    _infoLogger?.call('Analyzing performance bottlenecks...');

    final longRunningOperations = _metrics
        .getMetricNames()
        .where((name) =>
            name.startsWith('timer_') && (_metrics.getMetric(name) ?? 0) > 1000)
        .toList();

    if (longRunningOperations.isNotEmpty) {
      _errorLogger
          ?.call('Long running operations detected: $longRunningOperations');
    }
  }

  /// 生成性能报告
  String generatePerformanceReport() {
    final report = StringBuffer();
    report.writeln('Performance Report');
    report.writeln('==================');
    report.writeln('Metrics:');

    for (final name in _metrics.getMetricNames()) {
      report.writeln('$name: ${_metrics.getMetric(name)}');
    }

    report.writeln('Active Timers: ${_metrics.getActiveTimers()}');
    return report.toString();
  }

  /// 关闭性能监控
  Future<void> close() async {
    _reportingTimer?.cancel();
    try {
      await _vmService?.dispose();
    } catch (e) {
      _errorLogger?.call('Error closing VM Service', error: e);
    }
  }
}
