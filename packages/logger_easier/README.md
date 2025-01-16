### Logger Easier

![logo](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/images/logo.png)

A modern logging solution designed for Dart and Flutter applications. It offers rich features and flexible configuration options to simplify log management.

![screenshot](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/images/screenshot.png)

---

## Table of Contents

- [Table of Contents](#table-of-contents)
- [✨ Key Features](#-key-features)
- [📦 Installation](#-installation)
- [🚀 Getting Started](#-getting-started)
- [📖 Core Concepts](#-core-concepts)
  - [Log Levels](#log-levels)
  - [Log Middleware](#log-middleware)
    - [Built-in Middleware](#built-in-middleware)
    - [Custom Middleware](#custom-middleware)
  - [Log Rotation](#log-rotation)
    - [Rotation Strategies](#rotation-strategies)
    - [Compression Handlers](#compression-handlers)
    - [Rotation Configuration](#rotation-configuration)
- [🛠️ Advanced Usage](#️-advanced-usage)
  - [Custom Middleware](#custom-middleware-1)
  - [Log Encryption](#log-encryption)
- [✅ Best Practices](#-best-practices)
- [📚 API Documentation](#-api-documentation)
- [👏 Contribution Guide](#-contribution-guide)
- [📜 License](#-license)



## ✨ Key Features

- **Multi-level Log Management**: Supports seven log levels (TRACE, DEBUG, INFO, WARN, ERROR, CRITICAL, FATAL), allowing fine-grained control over log output.
- **Plugin-based Architecture**: Leverages middleware for extensibility. Easily integrate custom or third-party log handlers.
- **Powerful Log Rotation**: Offers size-based and time-based log rotation strategies with automatic compression and cleanup of old logs.
- **Diverse Output Options**: Supports console output (with colors), file output, custom outputs, and asynchronous logging.
- **High-performance Asynchronous Mode**: Ensures non-blocking log recording with batch processing for optimized performance.
- **Flexible Formatting and Filtering**: Customize log formats, including timestamps, levels, and error messages. Filter logs based on levels or patterns.
- **Runtime Monitoring**: Includes built-in performance tracking and error handling, measuring operation durations and capturing uncaught exceptions automatically.



## 📦 Installation

Add the dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  logger_easier: ^latest_version
```

Then run:

```bash
flutter pub get
```



## 🚀 Getting Started

```dart
import 'package:logger_easier/logger_easier.dart';

void main() {
  final logger = Logger(
    minLevel: LogLevel.debug,
    middlewares: [
      ConsoleMiddleware(),
      FileMiddleware(
        logDirectory: 'logs',
        baseFileName: 'app.log',
        rotateConfig: LogRotateConfig(
          strategy: SizeBasedStrategy(
            maxSize: 10 * 1024 * 1024, // 10MB
            maxBackups: 5,
          ),
        ),
      ),
    ],
  );

  logger.trace('This is a trace log');
  logger.debug('This is a debug log');
  logger.info('This is an info log');
  logger.warn('This is a warning log');
  logger.error('This is an error log', error: Exception('An error occurred'));
  logger.critical('This is a critical error log');
  logger.fatal('This is a fatal error log');
}
```



## 📖 Core Concepts

### Log Levels

Logger Easier supports seven log levels, ranked from lowest to highest severity:

- `TRACE`: Most detailed, usually for debugging.
- `DEBUG`: For debugging during development.
- `INFO`: General operational logs indicating progress.
- `WARN`: Non-critical issues or warnings.
- `ERROR`: Significant issues requiring attention.
- `CRITICAL`: Severe errors affecting overall application stability.
- `FATAL`: Irrecoverable errors, leading to application termination.

Control the output level via the `minLevel` parameter in `Logger`. For example, setting `minLevel` to `LogLevel.info` outputs only `INFO` and above levels.



### Log Middleware

Middleware in Logger Easier processes logs in specific stages like formatting, filtering, and output. Combine various middleware to customize your logging pipeline.

#### Built-in Middleware

- **`ConsoleMiddleware`**: Outputs logs to the console with color coding.
- **`FileMiddleware`**: Writes logs to files and supports rotation.

#### Custom Middleware

To create custom middleware, implement the `AbstractLogMiddleware` interface. Example: Sending logs to a remote server.



### Log Rotation

Prevent log files from becoming too large with automatic log rotation. 

#### Rotation Strategies

1. **Size-based** (`SizeBasedStrategy`): Rotate when file exceeds a specified size.
2. **Time-based** (`TimeBasedStrategy`): Rotate at fixed intervals.

#### Compression Handlers

Logger Easier supports file compression during rotation to save space. Implement the `CompressionHandler` interface for custom algorithms or use the built-in `GzipCompressionHandler`.

#### Rotation Configuration

Customize rotation with `LogRotateConfig`, which includes options like rotation strategy, compression, and storage monitoring.



## 🛠️ Advanced Usage

### Custom Middleware

Develop tailored middleware to integrate third-party services or unique log-handling logic.

### Log Encryption

Secure sensitive logs with encryption using the `LogEncryptor` class. Example:

```dart
final encryptor = LogEncryptor('your-secret-key');
await encryptor.encrypt(File('logs/app.log'), File('logs/app.log.enc'));
```

## ✅ Best Practices

- Initialize logging early in the app lifecycle.
- Choose appropriate log levels for clarity and performance.
- Avoid sensitive data exposure in logs.
- Regularly review and analyze logs for issues.
- Use rotation and compression to manage storage.


## 📚 API Documentation

Explore detailed API documentation: [API Reference](https://pub.dev/documentation/logger_easier/latest/)


## 👏 Contribution Guide

We welcome contributions via issues, pull requests, or documentation improvements. Please read [CONTRIBUTING.md](https://github.com/jacklee1995/flutter_logger_easier/blob/master/CONTRIBUTING.md) for details.

---

## 📜 License

This project is licensed under the MIT License. See [LICENSE](https://github.com/jacklee1995/flutter_logger_easier/blob/master/LICENSE) for more information.

Enjoy using Logger Easier! If you find this library helpful, give us a ⭐️.