import 'dart:convert';
import 'package:logger_easier/logger_easier.dart';
import 'json_outputer_config.dart';

class JsonOutputer implements AbstractOutputer {
  final JsonOutputerConfig _config;

  /// JSON 的缩进
  final String _indent;
  bool _closed = false;

  JsonOutputer({
    JsonOutputerConfig config = const JsonOutputerConfig(),
    String indent = '  ',
  })  : _config = config,
        _indent = indent;

  @override
  String printf(LogRecord record) {
    if (_closed) {
      throw StateError('Cannot write to a closed outputer');
    }

    final jsonMap = <String, dynamic>{
      'timestamp': record.timestamp.toIso8601String(),
      'level': record.level.name,
      'message': record.message,
    };

    if (_config.includeError && record.error != null) {
      jsonMap['error'] = record.error.toString();
    }

    if (_config.includeStackTrace && record.stackTrace != null) {
      jsonMap['stackTrace'] = record.stackTrace.toString();
    }

    final jsonString = jsonEncode(jsonMap);

    if (_config.pretty) {
      return _prettyPrintJson(jsonString);
    } else {
      return jsonString;
    }
  }

  String _prettyPrintJson(String jsonString) {
    final object = json.decode(jsonString);
    return JsonEncoder.withIndent(_indent).convert(object);
  }

  @override
  Future<void> init() async {
    // 在这里执行任何必要的初始化操作
  }

  @override
  Future<void> close() async {
    _closed = true;
  }

  @override
  String get name => 'JsonOutputer';

  @override
  Map<String, dynamic> get config => getConfigMap();

  Map<String, dynamic> getConfigMap() {
    return _config.toMap();
  }

  @override
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    // 在这里处理配置更新
  }

  @override
  bool get isClosed => _closed;

  @override
  List<String> get supportedLevels =>
      LogLevel.values.map((e) => e.name).toList();

  @override
  void setColorSupport(bool enabled) {
    // JSON 输出器不支持颜色,所以这里不做任何操作
  }

  @override
  Map<String, dynamic> getStats() {
    // 在这里返回输出器的统计信息
    return {};
  }

  @override
  void resetStats() {
    // 在这里重置输出器的统计信息
  }

  @override
  String formatError(dynamic error, StackTrace? stackTrace) {
    return 'Error: $error\nStackTrace: $stackTrace';
  }

  @override
  String formatMessage(dynamic message) => message.toString();

  @override
  String getLevelColor(LogLevel level) => '';

  @override
  String getLevelFgColor(LogLevel level) => '';

  @override
  String getLevelBgColor(LogLevel level) => '';
}
