import '../core/log_record.dart';

class LogAggregator {
  final Duration aggregationWindow;
  final int maxBatchSize;
  final Map<String, List<LogRecord>> _buffer = {};

  LogAggregator({
    this.aggregationWindow = const Duration(seconds: 10),
    this.maxBatchSize = 1000,
  });

  void aggregate(LogRecord record) {
    final key = _getAggregationKey(record);
    _buffer.putIfAbsent(key, () => []).add(record);

    if (_shouldFlush(key)) {
      flush(key);
    }
  }

  String _getAggregationKey(LogRecord record) {
    // 基于日志级别和来源生成聚合键
    return '${record.level}_${record.source}';
  }

  bool _shouldFlush(String key) {
    return _buffer[key]!.length >= maxBatchSize;
  }

  void flush(String key) {
    // 处理聚合的日志
    final records = _buffer.remove(key);
    if (records != null) {
      // 处理聚合记录...
    }
  }
}
