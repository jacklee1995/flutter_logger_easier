# Logger Easier

![logo](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/images/logo.png)

一个为 Dart 和 Flutter 应用程序设计的现代化日志管理解决方案。提供了丰富的功能和灵活的配置选项，让日志管理变得更简单。

![screenshot](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/images/screenshot.png)

## 目录

- [Logger Easier](#logger-easier)
  - [目录](#目录)
  - [✨ 核心特性](#-核心特性)
  - [📦 安装](#-安装)
  - [🚀 快速开始](#-快速开始)
  - [📖 核心概念](#-核心概念)
    - [日志级别](#日志级别)
    - [日志中间件](#日志中间件)
    - [日志轮转](#日志轮转)
      - [轮转策略](#轮转策略)
      - [压缩处理器](#压缩处理器)
      - [轮转配置](#轮转配置)
  - [🛠️ 高级用法](#️-高级用法)
    - [自定义中间件](#自定义中间件)
    - [日志加密](#日志加密)
    - [日志存储](#日志存储)
  - [✅ 最佳实践](#-最佳实践)
  - [📚 API 文档](#-api-文档)
  - [👏 贡献指南](#-贡献指南)
  - [📞 Support and Contact](#-support-and-contact)
  - [🌍 Language Support](#-language-support)
  - [📜 许可证](#-许可证)

## ✨ 核心特性

- **多级日志管理**: 支持 7 个日志级别(TRACE， DEBUG， INFO， WARN， ERROR， CRITICAL， FATAL)，可灵活控制日志输出粒度。
- **插件化架构**: 基于中间件模式，可自由组合和扩展日志处理功能。支持自定义中间件，轻松接入第三方服务。
- **强大的日志轮转**: 支持基于大小和时间的日志轮转策略，自动压缩和清理旧日志，避免日志文件过大。
- **丰富的输出方式**: 支持输出到控制台(彩色)、文件、自定义输出，以及异步写入模式，满足不同场景需求。
- **高性能异步模式**: 采用异步日志写入和批处理优化，确保极致的日志记录性能，不阻塞业务代码。
- **灵活的格式与过滤**: 支持自定义日志格式，包括时间戳、日志级别、错误信息等。可按级别、正则等规则过滤日志。
- **运行时监控**: 内置性能监控和错误处理功能，可测量关键操作耗时，自动捕获并上报未处理异常。

## 📦 安装

在项目的 `pubspec.yaml` 文件中添加依赖:

```yaml
dependencies:
  logger_easier: ^latest_version
```

然后执行 `flutter pub get` 安装依赖。

## 🚀 快速开始

```dart
import 'package:logger_easier/logger_easier.dart';

void main() {
  // 创建日志管理器实例
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
  
  // 记录不同级别的日志
  logger.trace('这是一条跟踪日志');
  logger.debug('这是一条调试日志');
  logger.info('这是一条信息日志');
  logger.warn('这是一条警告日志');
  logger.error('这是一条错误日志', error: Exception('发生了一个错误'));
  logger.critical('这是一条严重错误日志');
  logger.fatal('这是一条致命错误日志');
}
```

## 📖 核心概念

### 日志级别

Logger Easier 支持 7 个日志级别，从低到高分别是:

- `TRACE`: 最详细的日志信息，一般用于调试。
- `DEBUG`: 调试信息，用于开发和测试阶段。
- `INFO`: 一般信息，用于记录程序运行过程中的关键节点。
- `WARN`: 警告信息，表示发生了一些异常情况，但不影响程序的继续执行。
- `ERROR`: 错误信息，表示发生了严重的异常，可能导致部分功能不可用。
- `CRITICAL`: 严重错误信息，表示发生了严重的错误，整个应用可能无法继续运行。
- `FATAL`: 致命错误信息，表示发生了无法恢复的错误，应用必须终止。

可以通过设置 `Logger` 的 `minLevel` 参数来控制日志的输出级别。例如，将 `minLevel` 设置为 `LogLevel.info`，则只会输出 `INFO` 及以上级别的日志。

### 日志中间件

Logger Easier 采用中间件模式来处理日志，每个中间件负责日志处理的一个特定环节，例如格式化、过滤、输出等。通过组合不同的中间件，可以灵活地定制日志处理流程。

内置的中间件包括:

- `ConsoleMiddleware`: 将日志输出到控制台，支持彩色输出。
- `FileMiddleware`: 将日志写入文件，支持日志轮转。

可以通过实现 `AbstractLogMiddleware` 接口来自定义中间件，实现自己的日志处理逻辑。

### 日志轮转

为了避免日志文件过大，Logger Easier 支持日志轮转功能。当日志文件达到一定条件时(如大小或时间)，会自动对日志文件进行轮转，同时可以对旧的日志文件进行压缩或清理。

![logger_easier_for_log_rotate](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/images/logger_easier_for_log_rotate.gif)

#### 轮转策略

Logger Easier 内置了两种常用的日志轮转策略:

- 基于大小的轮转策略(`SizeBasedStrategy`): 当日志文件达到指定大小时进行轮转。可设置最大文件大小和最大备份数量。
- 基于时间的轮转策略(`TimeBasedStrategy`): 按照指定的时间间隔进行轮转。可设置轮转间隔和最大备份数量。

这两种策略都实现了 `RotateStrategy` 接口，该接口定义了以下方法:

- `shouldRotate(File logFile, int currentSize, DateTime lastRotateTime)`: 检查是否需要进行日志轮转。
- `getRotatedFileName(File originalFile, int rotateIndex)`: 生成轮转后文件的名称。
- `cleanupOldLogs(Directory directory, String pattern)`: 清理过期的日志文件。

#### 压缩处理器

在日志轮转过程中，Logger Easier 支持对旧的日志文件进行压缩，以节省存储空间。压缩处理器需要实现 `CompressionHandler` 接口，该接口定义了以下方法:

- `compress(File sourceFile, File targetFile)`: 压缩日志文件。
- `decompress(File sourceFile, File targetFile)`: 解压日志文件。
- `get compressedExtension`: 获取压缩文件的扩展名。

Logger Easier 内置了 `GzipCompressionHandler`，它使用 GZIP 算法对日志文件进行压缩和解压缩。你也可以实现自己的压缩处理器，以支持其他的压缩算法。

#### 轮转配置

可以通过配置 `LogRotateConfig` 来自定义轮转策略和相关参数，例如压缩处理器、延迟压缩、存储监控等。

`LogRotateConfig` 包含以下配置项:

- `strategy`: 日志轮转策略，可以是 `SizeBasedStrategy` 或 `TimeBasedStrategy`。
- `compressionHandler`: 压缩处理器，默认为 `null`(不压缩)。
- `delayCompress`: 是否延迟压缩，默认为 `true`。如果为 `true`，则压缩操作将在轮转后异步执行;如果为 `false`，则会在轮转时立即执行压缩。
- `checkInterval`: 日志轮转检查的时间间隔，默认为每 5 分钟检查一次。
- `enableAsyncRotation`: 是否启用异步轮转，默认为 `true`。如果为 `true`，则日志轮转将在异步队列中执行，允许多个日志文件并行轮转。
- `rotationQueueSize`: 异步轮转队列的最大大小，控制并发轮转的数量，默认为 100。
- `enableStorageMonitoring`: 是否启用存储空间监控，默认为 `true`。如果为 `true`，则会在轮转时检查磁盘空间，如果剩余空间不足，则会停止日志轮转。
- `minimumFreeSpace`: 存储空间的最小剩余要求，默认为 100MB。

以下是一个配置日志轮转的示例:

```dart
final logger = Logger(
  minLevel: LogLevel.debug,
  middlewares: [
    FileMiddleware(
      logDirectory: 'logs',
      baseFileName: 'app.log',
      rotateConfig: LogRotateConfig(
        strategy: SizeBasedStrategy(
          maxSize: 10 * 1024 * 1024, // 10MB
          maxBackups: 5,
        ),
        compressionHandler: GzipCompressionHandler(),
        delayCompress: true,
        checkInterval: Duration(minutes: 1),
        enableAsyncRotation: true,
        rotationQueueSize: 50,
        enableStorageMonitoring: true,
        minimumFreeSpace: 50 * 1024 * 1024, // 50MB  
      ),
    ),
  ],
);
```

在上面的示例中，我们配置了基于大小的轮转策略，最大文件大小为 10MB，最大备份数量为 5。同时启用了 GZIP 压缩、延迟压缩、异步轮转和存储监控等功能。

## 🛠️ 高级用法

### 自定义中间件

通过实现 `AbstractLogMiddleware` 接口，可以创建自定义的日志中间件来扩展日志处理功能。例如，实现一个将日志发送到远程服务器的中间件:

```dart
class RemoteLogMiddleware extends AbstractLogMiddleware {
  @override
  AbstractOutputer createOutputer() {
    return RemoteOutputer();
  }

  @override
  AbstractLogFormatter createFormatter() {
    return JsonFormatter();
  }

  @override
  AbstractLogFilter createFilter() {
    // 只发送 WARN 及以上级别的日志到远程服务器
    return LevelFilter(minLevel: LogLevel.warn);
  }
}

class RemoteOutputer extends AbstractOutputer {
  @override
  String printf(LogRecord record) {
    // 将日志发送到远程服务器
    sendLogToRemote(record);
    return '';
  }

  Future<void> sendLogToRemote(LogRecord record) async {
    // TODO: 实现发送日志到远程服务器的逻辑
  }

  @override
  String get name => 'RemoteOutputer';

  @override
  Map<String, dynamic> get config => {};
}

class JsonFormatter extends AbstractLogFormatter {
  @override
  String format(LogRecord record) {
    return json.encode({
      'timestamp': record.timestamp.toIso8601String(),
      'level': record.level.name,
      'message': record.message,
      'error': record.error?.toString(),
      'stackTrace': record.stackTrace?.toString(),
    });
  }

  @override
  String get name => 'JsonFormatter';

  @override
  Map<String, dynamic> get config => {};
}
```

在上面的示例中，我们定义了一个 `RemoteLogMiddleware`，它包含以下组件:

- `RemoteOutputer`: 负责将日志发送到远程服务器。
- `JsonFormatter`: 将日志格式化为 JSON 格式。
- `LevelFilter`: 只允许 WARN 及以上级别的日志通过。

通过组合这些组件，我们实现了一个自定义的中间件，可以将重要的日志以 JSON 格式发送到远程服务器进行集中管理和监控。

你可以根据实际需求，定制适合自己的中间件组件，例如将日志发送到 Sentry、Loggly 等第三方日志服务，，或者将日志保存到数据库中等。

### 日志加密

在某些安全性要求较高的场景下，可能需要对日志内容进行加密，以防止敏感信息泄露。Logger Easier 提供了一个 `LogEncryptor` 类，用于对日志文件进行加密和解密。

```dart
// 创建加密器实例
final encryptor = LogEncryptor('your-secret-key');

// 加密日志文件
await encryptor.encrypt(File('logs/app.log'), File('logs/app.log.enc'));

// 解密日志文件  
await encryptor.decrypt(File('logs/app.log.enc'), File('logs/app.log'));
```

`LogEncryptor` 使用 AES 算法对日志文件进行加密，你需要提供一个密钥字符串。加密后的文件以 `.enc` 为后缀名。

> 注意:日志加密会对性能产生一定影响，请根据实际需求权衡是否启用。

### 日志存储

除了将日志写入文件，Logger Easier 还支持将日志保存到其他存储介质，如数据库、NoSQL 等。你可以通过实现 `LogStorage` 接口来自定义日志存储方式。

```dart
class MongoDBLogStorage extends LogStorage {
  final Db db;
  final String collectionName;

  MongoDBLogStorage({required this.db, this.collectionName = 'logs'});

  @override
  Future<void> write(LogRecord record) async {
    await db.collection(collectionName).insertOne({
      'timestamp': record.timestamp,
      'level': record.level.name,
      'message': record.message,
      'error': record.error?.toString(),
      'stackTrace': record.stackTrace?.toString(),
    });
  }
}
```

上面的示例演示了如何将日志保存到 MongoDB 数据库中。你可以将 `MongoDBLogStorage` 传递给 `FileMiddleware`，替代默认的文件存储:

```dart
final logger = Logger(
  minLevel: LogLevel.debug,
  middlewares: [
    FileMiddleware(
      logDirectory: 'logs',
      logStorage: MongoDBLogStorage(db: db),
    ),
  ],
);
```

这样，日志就会被写入到 MongoDB 数据库中，而不是文件系统。

你还可以实现其他的存储方式，如 MySQL、PostgreSQL、Redis 等，以满足不同的需求。

## ✅ 最佳实践

- 在应用程序启动时尽早初始化日志系统，确保在整个应用生命周期内都能记录日志。
- 根据实际需求选择合适的日志级别，避免记录过多的低级别日志，影响性能和可读性。
- 合理设置日志轮转策略，避免单个日志文件过大或过多，占用过多存储空间。
- 谨慎记录敏感信息，如用户隐私数据、密码等。必要时进行脱敏处理，或使用日志加密功能。
- 充分利用日志中间件的灵活性，定制适合项目的日志处理流程，如接入第三方日志服务。
- 在关键业务逻辑和可能出错的地方记录日志，方便问题定位和追踪。
- 养成查看和分析日志的习惯，及时发现和解决潜在问题。
- 选择合适的日志存储方式，如文件、数据库等，并进行定期备份和清理。
- 合理使用异步写入和批处理等优化技术，提高日志记录的性能。
- 在发布到生产环境前，对日志系统进行充分的测试，确保其稳定性和可靠性。

## 📚 API 文档

详细的 API 文档请参考: [API Reference](https://pub.dev/documentation/logger_easier/latest/)

## 👏 贡献指南

如果您在使用过程中遇到任何问题或有任何建议，欢迎提出 Issue 或提交 Pull Request。
欢迎通过以下方式参与本项目：

- 提交问题 (Issues)
- 发起拉取请求 (Pull Requests)
- 改进文档
- 分享使用体验

请阅读 [CONTRIBUTING.md](https://github.com/jacklee1995/flutter_logger_easier/blob/master/CONTRIBUTING.md) 以获取详细的贡献指南。

## 📞 Support and Contact

- GitHub Issues: [Submit Issue](https://github.com/jacklee1995/flutter_logger_easier/issues)
- Email: [291148484@163.com](mailto:291148484@163.com)

## 🌍 Language Support

- [English](README.md)
- [中文](README_CN.md)

## 📜 许可证

本项目基于 MIT 许可证发布。详细信息请参考 [LICENSE](https://github.com/jacklee1995/flutter_logger_easier/blob/master/LICENSE) 文件。

---

感谢使用 Logger Easier！如果您觉得这个库对您有帮助，欢迎给我们一个 Star ⭐️。

**注意**：Logger Easier 正在持续开发中，API 可能会发生变更。建议关注版本更新。此文档可能会比代码更新稍滞后，因此请务必参考示例项目以获取使用方法。
