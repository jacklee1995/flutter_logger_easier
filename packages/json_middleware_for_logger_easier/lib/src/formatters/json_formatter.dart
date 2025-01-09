import 'dart:convert';
import 'package:logger_easier/logger_easier.dart';

import 'json_formatter_config.dart';

class JsonFormatter implements AbstractLogFormatter<JsonFormatterConfig> {
  final JsonFormatterConfig _config;

  JsonFormatter({JsonFormatterConfig config = const JsonFormatterConfig()})
      : _config = config;

  @override
  String format(LogRecord record) {
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

    String jsonString = jsonEncode(jsonMap);

    if (_config.includeSeparator) {
      jsonString += _config.separator;
    }

    return jsonString;
  }

  @override
  String get name => 'JsonFormatter';

  @override
  JsonFormatterConfig get config => _config;

  @override
  void updateConfig(Map<String, dynamic> newConfig) {
    // 由于 JsonFormatterConfig 的字段是 final 的,所以这里不做任何操作
  }

  @override
  AbstractLogFormatter clone() => JsonFormatter(config: _config);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonFormatter &&
          runtimeType == other.runtimeType &&
          _config == other._config;

  @override
  int get hashCode => _config.hashCode;

  @override
  String toString() => 'JsonFormatter(config: $_config)';

  @override
  List<String> get supportedPlaceholders => [];

  @override
  bool isValidFormatString(String formatString) => true;
}
