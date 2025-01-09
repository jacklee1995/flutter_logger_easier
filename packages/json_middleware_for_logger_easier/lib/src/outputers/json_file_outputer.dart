import 'dart:convert';
import 'dart:io';
import 'package:logger_easier/logger_easier.dart';
import 'json_outputer_config.dart';

class JsonFileOutputer implements AbstractOutputer {
  final JsonOutputerConfig _config;
  final String _filePath;
  IOSink? _sink;
  bool _closed = false;

  JsonFileOutputer({
    required String filePath,
    JsonOutputerConfig config = const JsonOutputerConfig(),
  })  : _filePath = filePath,
        _config = config;

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
      _sink?.writeln(_prettyPrintJson(jsonString));
    } else {
      _sink?.writeln(jsonString);
    }

    return jsonString;
  }

  String _prettyPrintJson(String jsonString) {
    final object = json.decode(jsonString);
    return JsonEncoder.withIndent('  ').convert(object);
  }

  @override
  Future<void> init() async {
    final file = File(_filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    _sink = file.openWrite(mode: FileMode.append);
  }

  @override
  Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
    _closed = true;
  }

  @override
  String get name => 'JsonFileOutputer';

  @override
  Map<String, dynamic> get config => getConfigMap();

  Map<String, dynamic> getConfigMap() {
    return {
      'filePath': _filePath,
      ..._config.toMap(),
    };
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
    // JSON 文件输出器不支持颜色,所以这里不做任何操作
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
