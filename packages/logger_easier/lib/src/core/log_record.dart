import 'dart:convert' show json;
import 'log_level.dart' show LogLevel;

/// 表示单个日志记录的类
class LogRecord {
  /// 日志记录的唯一标识符
  final String id;

  /// 日志记录的时间戳
  final DateTime timestamp;

  /// 日志级别
  final LogLevel level;

  /// 日志消息
  final String message;

  /// 相关的错误对象（如果有）
  final dynamic error;

  /// 错误的堆栈跟踪（如果有）
  final StackTrace? stackTrace;

  /// 日志记录的来源（例如，类名或文件名）
  final String? source;

  /// 与日志记录相关的额外数据
  final Map<String, dynamic>? extra;

  /// 构造函数
  LogRecord(
    this.level,
    this.message, {
    String? id,
    DateTime? timestamp,
    this.error,
    this.stackTrace,
    this.source,
    this.extra,
  })  : id = id ?? _generateId(),
        timestamp = timestamp ?? DateTime.now();

  /// 生成唯一的日志记录ID
  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  /// 创建 LogRecord 的副本，可选择性地覆盖某些字段
  LogRecord copyWith({
    LogLevel? level,
    String? message,
    DateTime? timestamp,
    dynamic error,
    StackTrace? stackTrace,
    String? source,
    Map<String, dynamic>? extra,
  }) {
    return LogRecord(
      level ?? this.level,
      message ?? this.message,
      id: id,
      timestamp: timestamp ?? this.timestamp,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      source: source ?? this.source,
      extra: extra ?? this.extra,
    );
  }

  /// 将 LogRecord 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.toString(),
      'message': message,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'source': source,
      'extra': extra,
    };
  }

  /// 从 Map 创建 LogRecord
  factory LogRecord.fromMap(Map<String, dynamic> map) {
    return LogRecord(
      LogLevel.values.firstWhere((e) => e.toString() == map['level']),
      map['message'],
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      error: map['error'],
      stackTrace: map['stackTrace'] != null
          ? StackTrace.fromString(map['stackTrace'])
          : null,
      source: map['source'],
      extra: map['extra'],
    );
  }

  /// 将 LogRecord 转换为 JSON 字符串
  String toJson() => json.encode(toMap());

  /// 从 JSON 字符串创建 LogRecord
  factory LogRecord.fromJson(String source) =>
      LogRecord.fromMap(json.decode(source));

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$timestamp [$level] ');
    if (source != null) buffer.write('($source) ');
    buffer.write(message);
    if (error != null) buffer.write('\nError: $error');
    if (stackTrace != null) buffer.write('\nStack trace:\n$stackTrace');
    if (extra != null && extra!.isNotEmpty) buffer.write('\nExtra: $extra');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogRecord &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.level == level &&
        other.message == message &&
        other.error == error &&
        other.stackTrace == stackTrace &&
        other.source == source &&
        other.extra == extra;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timestamp.hashCode ^
        level.hashCode ^
        message.hashCode ^
        error.hashCode ^
        stackTrace.hashCode ^
        source.hashCode ^
        extra.hashCode;
  }
}
