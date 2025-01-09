# Logger Easier

![logo](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/logo.png)

## 🌟 Project Introduction

Logger Easier is a modern logging management solution tailored specifically for Dart and Flutter applications. It provides a highly flexible and feature-rich logging system designed to simplify developers' log management while offering significant customization capabilities.

![alt text](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/example.png)

## ✨ Core Features

1. Multi-Level Log Management
   - Supports 7 log levels: Trace, Debug, Info, Warn, Error, Critical, Fatal
   - Fine-grained log level control
   - Configurable minimum log recording level

2. Flexible Log Output
   - Console output (supports colored logs)
   - File logging
   - Custom output destinations
   - Log file rotation and compression

3. Advanced Log Formatting
   - Customizable log formats
   - Supports multiple log format templates
   - Rich log record metadata (timestamps, source, error information, etc.)

4. Performance Monitoring
   - Built-in performance measurement methods
   - Async and sync operation performance tracking
   - Automatic performance metric recording and reporting

5. Error Handling
   - Automatic error reporting
   - Stack trace recording
   - Pluggable error reporter

6. Singleton Mode
   - Unified global log management
   - Simple initialization and usage

7. Extensibility
   - Supports custom log processors
   - Pluggable components (printers, outputs, formatters, filters)

## 📦 Installation

Add the dependency in `pubspec.yaml`:

```yaml
dependencies:
  logger_easier: ^0.0.1
```

Run `dart pub get` or `flutter pub get` to install the dependency.

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:logger_easier/logger_easier.dart';

void main() {
  // Create default logger instance
  final logger = Logger();

  // Log different levels
  logger.debug('Debug information');
  logger.info('General information');
  logger.warn('Warning information');
  logger.error('Error information', error: Exception('Sample error'));
}
```

### File Logging Configuration

```dart
final logger = Logger(
  logDirectory: '/path/to/logs',
  baseFileName: 'app.log',
  maxFileSize: 10 * 1024 * 1024, // 10MB
  maxBackupIndex: 5,
  compress: true,
);
```

### Performance Measurement

```dart
// Async performance measurement
final result = await logger.measurePerformance('complex_operation', () async {
  return await complexOperation();
});

// Sync performance measurement
final syncResult = logger.measureSyncPerformance('simple_operation', () {
  return simpleOperation();
});
```

### Custom Log Processing

```dart
final customLogger = Logger(
  middlewares: [
    LogMiddleware(
      printer: CustomPrinter(),
      output: CustomOutput(),
      formatter: CustomFormatter(),
      filter: CustomFilter(),
    )
  ]
);
```

## 🌈 Log Levels

Logger Easier supports 7 log levels, increasing in severity:

1. `trace`: Most detailed tracing information, for fine-grained diagnostics
2. `debug`: Debug information, used for development and diagnostics
3. `info`: Regular information, important application events
4. `warn`: Warning information, potential problems or exceptional situations
5. `error`: Error information, issues causing functional anomalies
6. `critical`: Critical errors, severely affecting system operation
7. `fatal`: Fatal errors, system unable to continue running

## 📝 Best Practices

1. Initialize logging during application startup
2. Use appropriate log levels
3. Disable verbose logs in production environments
4. Regularly clean and archive log files
5. Protect sensitive information, avoid recording sensitive data in logs

## 🔒 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🤝 Contribution Guidelines

Welcome to participate in the project through:

- Submitting Issues
- Initiating Pull Requests
- Improving documentation
- Sharing usage experiences

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

## 📞 Support and Contact

- GitHub Issues: [Submit Issue](https://github.com/jacklee1995/flutter_logger_easier/issues)
- Email: [291148484@163.com](mailto:291148484@163.com)

## 🌍 Language Support

- [English](README.md)
- [中文](README_CN.md)

---

**Note**: Logger Easier is under continuous development, and the API may change. It is recommended to follow version updates. This documentation may be updated later than the code, so please be sure to refer to the example project for usage.
