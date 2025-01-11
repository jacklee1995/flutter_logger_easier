import 'dart:async';
import 'dart:collection';
import 'abstract_outputer.dart';
import '../core/log_record.dart';

/// 异步日志输出器的抽象基类
///
/// 扩展了 [AbstractOutputer]，为需要异步操作的输出器（如文件输出器）提供基础实现。
/// 处理异步写入、缓冲和错误恢复等复杂场景。
abstract class AsyncOutputer implements AbstractOutputer {
  static const int _defaultMaxQueueSize = 1000;
  static const Duration _defaultFlushInterval = Duration(seconds: 1);
  static const int _defaultMaxRetries = 3;
  static const Duration _defaultRetryDelay = Duration(milliseconds: 100);

  final Queue<LogRecord> _buffer = Queue<LogRecord>();
  final StreamController<LogRecord> _recordController =
      StreamController<LogRecord>.broadcast();

  Timer? _flushTimer;
  bool _isProcessing = false;
  bool _isClosed = false;
  int _failedAttempts = 0;

  // 配置项
  int _maxQueueSize;
  Duration _flushInterval;
  int _maxRetries;
  Duration _retryDelay;

  // Getters
  int get maxQueueSize => _maxQueueSize;
  Duration get flushInterval => _flushInterval;
  int get maxRetries => _maxRetries;
  Duration get retryDelay => _retryDelay;

  // Setters
  set maxQueueSize(int value) {
    if (value > 0) {
      _maxQueueSize = value;
    }
  }

  set flushInterval(Duration value) {
    _flushInterval = value;
    _flushTimer?.cancel();
    _startFlushTimer();
  }

  set maxRetries(int value) {
    if (value > 0) {
      _maxRetries = value;
    }
  }

  set retryDelay(Duration value) {
    _retryDelay = value;
  }

  AsyncOutputer({
    int maxQueueSize = _defaultMaxQueueSize,
    Duration flushInterval = _defaultFlushInterval,
    int maxRetries = _defaultMaxRetries,
    Duration retryDelay = _defaultRetryDelay,
  })  : _maxQueueSize = maxQueueSize,
        _flushInterval = flushInterval,
        _maxRetries = maxRetries,
        _retryDelay = retryDelay {
    _startProcessor();
    _startFlushTimer();
  }

  /// 异步处理单条日志记录
  Future<void> processRecord(LogRecord record);

  /// 异步批处理多条日志记录
  /// 子类可以重写此方法以实现批处理优化
  Future<void> processBatch(List<LogRecord> records) async {
    for (final record in records) {
      await processRecord(record);
    }
  }

  /// 启动异步处理器
  void _startProcessor() {
    _recordController.stream.listen((record) {
      _buffer.add(record);

      // 如果缓冲区达到最大大小，立即刷新
      if (_buffer.length >= maxQueueSize) {
        _flush();
      }
    });
  }

  /// 启动定时刷新器
  void _startFlushTimer() {
    _flushTimer = Timer.periodic(flushInterval, (_) => _flush());
  }

  /// 刷新缓冲区
  Future<void> _flush() async {
    if (_isProcessing || _buffer.isEmpty || _isClosed) return;
    _isProcessing = true;

    try {
      final records = List<LogRecord>.from(_buffer);
      _buffer.clear();

      await _processWithRetry(() => processBatch(records));
      _failedAttempts = 0; // 重置失败计数
    } catch (e, stack) {
      _handleError(e, stack);
    } finally {
      _isProcessing = false;
    }
  }

  /// 带重试的处理逻辑
  Future<void> _processWithRetry(Future<void> Function() operation) async {
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await operation();
        return;
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        await Future.delayed(retryDelay * attempt);
      }
    }
  }

  /// 错误处理
  void _handleError(dynamic error, StackTrace stackTrace) {
    _failedAttempts++;
    print('Error in AsyncOutputer: $error\n$stackTrace');

    // 如果连续失败次数过多，可以采取措施
    if (_failedAttempts >= maxRetries) {
      // 可以实现降级策略，如切换到备用存储
      print(
          'Too many consecutive failures, consider implementing fallback strategy');
    }
  }

  @override
  String printf(LogRecord record) {
    if (_isClosed) {
      throw StateError('AsyncOutputer is closed');
    }

    final output = formatMessage(record.message);
    _recordController.add(record);
    return output;
  }

  @override
  Future<void> init() async {
    _isClosed = false;
    _startProcessor();
    _startFlushTimer();
  }

  @override
  Future<void> close() async {
    _isClosed = true;
    _flushTimer?.cancel();

    // 最后一次刷新
    if (_buffer.isNotEmpty) {
      await _flush();
    }

    await _recordController.close();
  }

  @override
  bool get isClosed => _isClosed;

  @override
  Map<String, dynamic> getStats() => {
        'isProcessing': _isProcessing,
        'isClosed': _isClosed,
        'bufferSize': _buffer.length,
        'failedAttempts': _failedAttempts,
        'maxQueueSize': maxQueueSize,
        'flushInterval': flushInterval.inMilliseconds,
      };

  @override
  void resetStats() {
    _failedAttempts = 0;
  }

  @override
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    if (newConfig.containsKey('maxQueueSize')) {
      final newSize = newConfig['maxQueueSize'] as int;
      if (newSize > 0) {
        _maxQueueSize = newSize;
      }
    }

    if (newConfig.containsKey('flushInterval')) {
      final newInterval = newConfig['flushInterval'] as int;
      if (newInterval > 0) {
        _flushInterval = Duration(milliseconds: newInterval);
        _flushTimer?.cancel();
        _startFlushTimer();
      }
    }

    if (newConfig.containsKey('maxRetries')) {
      final newRetries = newConfig['maxRetries'] as int;
      if (newRetries > 0) {
        _maxRetries = newRetries;
      }
    }

    if (newConfig.containsKey('retryDelay')) {
      final newDelay = newConfig['retryDelay'] as int;
      if (newDelay > 0) {
        _retryDelay = Duration(milliseconds: newDelay);
      }
    }
  }
}
