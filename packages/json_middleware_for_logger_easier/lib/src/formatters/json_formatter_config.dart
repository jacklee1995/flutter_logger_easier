class JsonFormatterConfig {
  final bool includeError;
  final bool includeStackTrace;
  final bool includeSeparator;
  final String separator;

  static const defaultIncludeError = true;
  static const defaultIncludeStackTrace = false;
  static const defaultIncludeSeparator = false;
  static const defaultSeparator = '\n';

  const JsonFormatterConfig({
    this.includeError = defaultIncludeError,
    this.includeStackTrace = defaultIncludeStackTrace,
    this.includeSeparator = defaultIncludeSeparator,
    this.separator = defaultSeparator,
  });

  JsonFormatterConfig copyWith({
    bool? includeError,
    bool? includeStackTrace,
    bool? includeSeparator,
    String? separator,
  }) {
    return JsonFormatterConfig(
      includeError: includeError ?? this.includeError,
      includeStackTrace: includeStackTrace ?? this.includeStackTrace,
      includeSeparator: includeSeparator ?? this.includeSeparator,
      separator: separator ?? this.separator,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'includeError': includeError,
      'includeStackTrace': includeStackTrace,
      'includeSeparator': includeSeparator,
      'separator': separator,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonFormatterConfig &&
          runtimeType == other.runtimeType &&
          includeError == other.includeError &&
          includeStackTrace == other.includeStackTrace &&
          includeSeparator == other.includeSeparator &&
          separator == other.separator;

  @override
  int get hashCode =>
      includeError.hashCode ^
      includeStackTrace.hashCode ^
      includeSeparator.hashCode ^
      separator.hashCode;

  @override
  String toString() {
    return 'JsonFormatterConfig(includeError: $includeError, '
        'includeStackTrace: $includeStackTrace, '
        'includeSeparator: $includeSeparator, '
        'separator: $separator)';
  }
}
