import '../core/log_level.dart' show LogLevel;

class RotationErrorHandler {
  final void Function(String message, [Exception? error])? onError;
  final void Function(String message)? onWarning;
  final void Function(String message)? onInfo;
  final LogLevel minimumLevel;

  RotationErrorHandler({
    this.onError,
    this.onWarning,
    this.onInfo,
    this.minimumLevel = LogLevel.warn,
  });

  void handleError(String message, [Exception? error]) {
    if (minimumLevel.index <= LogLevel.error.index) {
      final errorMessage = error != null ? '$message: $error' : message;
      onError?.call(errorMessage, error);
    }
  }

  void handleWarning(String message) {
    if (minimumLevel.index <= LogLevel.warn.index) {
      onWarning?.call(message);
    }
  }

  void handleInfo(String message) {
    if (minimumLevel.index <= LogLevel.info.index) {
      onInfo?.call(message);
    }
  }
}
