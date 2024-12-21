import 'dart:collection';

/// 性能指标类,用于存储和管理各种性能相关的指标
class PerformanceMetrics {
  final Map<String, num> _metrics = HashMap<String, num>();
  final Map<String, Stopwatch> _timers = HashMap<String, Stopwatch>();

  /// 设置一个数值型指标
  void setMetric(String name, num value) {
    _metrics[name] = value;
  }

  /// 获取一个数值型指标
  num? getMetric(String name) {
    return _metrics[name];
  }

  /// 获取所有指标
  Map<String, num> getAllMetrics() {
    return Map.from(_metrics);
  }

  /// 增加一个数值型指标的值
  void incrementMetric(String name, [num increment = 1]) {
    _metrics[name] = (_metrics[name] ?? 0) + increment;
  }

  /// 开始计时一个指标
  void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// 停止计时一个指标并记录耗时
  void stopTimer(String name) {
    if (_timers.containsKey(name)) {
      final elapsed = _timers[name]!.elapsedMilliseconds;
      setMetric(name, elapsed);
      _timers.remove(name);
    }
  }

  /// 记录一个事件的发生次数
  void recordEvent(String eventName) {
    incrementMetric(eventName);
  }

  /// 获取所有指标的快照
  Map<String, num> getSnapshot() {
    return Map.from(_metrics);
  }

  /// 重置所有指标
  void reset() {
    _metrics.clear();
    _timers.clear();
  }

  /// 移除一个指标
  void removeMetric(String name) {
    _metrics.remove(name);
    _timers.remove(name);
  }

  /// 检查是否存在某个指标
  bool hasMetric(String name) {
    return _metrics.containsKey(name) || _timers.containsKey(name);
  }

  /// 获取正在计时的指标列表
  List<String> getActiveTimers() {
    return _timers.keys.toList();
  }

  /// 获取所有指标的名称
  List<String> getMetricNames() {
    return _metrics.keys.toList();
  }

  /// 计算平均值
  void calculateAverage(String totalName, String countName, String averageName) {
    if (_metrics.containsKey(totalName) && _metrics.containsKey(countName)) {
      final total = _metrics[totalName]!;
      final count = _metrics[countName]!;
      if (count > 0) {
        setMetric(averageName, total / count);
      }
    }
  }

  @override
  String toString() {
    return _metrics.toString();
  }
}