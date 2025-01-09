class JsonOutputerConfig {
  final bool pretty;
  final bool includeError;
  final bool includeStackTrace;

  static const defaultPretty = false;
  static const defaultIncludeError = true;
  static const defaultIncludeStackTrace = false;

  const JsonOutputerConfig({
    this.pretty = defaultPretty,
    this.includeError = defaultIncludeError,
    this.includeStackTrace = defaultIncludeStackTrace,
  });

  JsonOutputerConfig copyWith({
    bool? pretty,
    bool? includeError,
    bool? includeStackTrace,
  }) {
    return JsonOutputerConfig(
      pretty: pretty ?? this.pretty,
      includeError: includeError ?? this.includeError,
      includeStackTrace: includeStackTrace ?? this.includeStackTrace,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pretty': pretty,
      'includeError': includeError,
      'includeStackTrace': includeStackTrace,
    };
  }

  factory JsonOutputerConfig.fromMap(Map<String, dynamic> map) {
    return JsonOutputerConfig(
      pretty: map['pretty'] ?? defaultPretty,
      includeError: map['includeError'] ?? defaultIncludeError,
      includeStackTrace: map['includeStackTrace'] ?? defaultIncludeStackTrace,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonOutputerConfig &&
          runtimeType == other.runtimeType &&
          pretty == other.pretty &&
          includeError == other.includeError &&
          includeStackTrace == other.includeStackTrace;

  @override
  int get hashCode =>
      pretty.hashCode ^ includeError.hashCode ^ includeStackTrace.hashCode;

  @override
  String toString() {
    return 'JsonOutputerConfig(pretty: $pretty, '
        'includeError: $includeError, '
        'includeStackTrace: $includeStackTrace)';
  }
}
