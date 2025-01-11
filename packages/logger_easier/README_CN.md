# Logger Easier

![logo](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/logo.png)

一个为 Dart 和 Flutter 应用程序设计的现代化日志管理解决方案。提供了丰富的功能和灵活的配置选项，让日志管理变得更简单。

## 目录

- [Logger Easier](#logger-easier)
  - [目录](#目录)
  - [特性](#特性)
  - [安装](#安装)
  - [快速开始](#快速开始)
    - [基础用法](#基础用法)
    - [使用日志助手](#使用日志助手)
  - [详细用法](#详细用法)
    - [日志级别](#日志级别)
    - [日志轮转](#日志轮转)
      - [基于大小的轮转](#基于大小的轮转)
      - [基于时间的轮转](#基于时间的轮转)
    - [日志格式化](#日志格式化)
    - [性能监控](#性能监控)
    - [错误处理](#错误处理)
  - [高级特性](#高级特性)
    - [自定义中间件](#自定义中间件)
    - [存储监控](#存储监控)
  - [最佳实践](#最佳实践)
  - [API 文档](#api-文档)
  - [贡献指南](#贡献指南)
  - [许可证](#许可证)

## 特性

- **多级日志管理**
  - 支持 7 个日志级别：TRACE、DEBUG、INFO、WARN、ERROR、CRITICAL、FATAL
  - 灵活的日志级别控制
  - 可配置的最小日志记录级别

- **强大的日志轮转**
  - 支持基于大小的轮转策略
  - 支持基于时间的轮转策略
  - 自动压缩和清理旧日志
  - 可配置的存储空间监控

- **丰富的输出选项**
  - 控制台彩色输出
  - 文件日志记录
  - 自定义输出目标
  - 异步日志处理

- **高级格式化**
  - 可定制的日志格式
  - 支持时间戳、日志级别、源文件等信息
  - 堆栈跟踪格式化
  - 错误信息美化

- **性能监控**
  - 内置性能度量
  - 异步操作追踪
  - 自动性能报告

- **错误处理**
  - 全局错误捕获
  - 详细的错误报告
  - 崩溃分析
  - 错误恢复机制

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  logger_easier: ^0.0.3
```

然后运行：

```bash
flutter pub get
```

## 快速开始

### 基础用法

```dart
import 'package:logger_easier/logger_easier.dart';

// 创建基于大小的日志配置
class SizeBasedLoggerConfig {
  static final instance = SizeBasedLoggerConfig._();
  late final Logger _logger;
  
  Future<void> initialize() async {
    final consoleMiddleware = ConsoleMiddleware(
      formatter: BaseFormatter(),
      filter: LevelFilter(LogLevel.debug),
    );
    
    final fileMiddleware = FileMiddleware(
      logDirectory: 'logs',
      baseFileName: 'app.log',
      rotateConfig: LogRotateConfig(
        strategy: SizeBasedStrategy(
          maxSize: 10 * 1024 * 1024, // 10MB
          maxBackups: 5,
        ),
      ),
    );

    _logger = Logger()
      ..use(consoleMiddleware)
      ..use(fileMiddleware);
  }
}

// 使用日志
void main() async {
  await SizeBasedLoggerConfig.instance.initialize();
  
  final logger = SizeBasedLoggerConfig.instance.logger;
  
  logger.info('应用启动');
  logger.debug('调试信息');
  logger.error('发生错误', error: Exception('测试错误'));
}
```

### 使用日志助手

```dart
import 'log_helper.dart';

// 使用统一的日志接口
Log.info('这是一条信息');
Log.error('发生错误', error: e, stackTrace: s);

// 性能监控
final result = await Log.measureAsync('操作名称', () async {
  // 异步操作
});

final syncResult = Log.measure('同步操作', () {
  // 同步操作
  return someValue;
});
```

## 详细用法

### 日志级别

Logger Easier 支持 7 个日志级别，按严重程度递增：

```dart
// 跟踪级别 - 最详细的调试信息
logger.trace('详细的跟踪信息');

// 调试级别 - 调试信息
logger.debug('调试信息');

// 信息级别 - 一般信息
logger.info('操作成功');

// 警告级别 - 潜在问题
logger.warn('配置过期');

// 错误级别 - 错误信息
logger.error('操作失败', error: e, stackTrace: s);

// 严重错误 - 需要立即关注
logger.critical('服务不可用');

// 致命错误 - 导致应用程序崩溃的错误
logger.fatal('系统崩溃');
```

### 日志轮转

#### 基于大小的轮转

```dart
final sizeBasedConfig = LogRotateConfig(
  strategy: SizeBasedStrategy(
    maxSize: 10 * 1024 * 1024, // 10MB
    maxBackups: 5,
  ),
  compressionHandler: GzipCompressionHandler(),
  enableStorageMonitoring: true,
  minimumFreeSpace: 100 * 1024 * 1024, // 100MB
);
```

#### 基于时间的轮转

```dart
final timeBasedConfig = LogRotateConfig(
  strategy: TimeBasedStrategy(
    rotateInterval: Duration(days: 1),
    maxBackups: 7,
  ),
  compressionHandler: GzipCompressionHandler(),
  delayCompress: true,
);
```

### 日志格式化

```dart
final formatter = BaseFormatter(
  includeTimestamp: true,
  includeLevel: true,
  includeStackTrace: true,
);

final middleware = ConsoleMiddleware(formatter: formatter);
```

### 性能监控

```dart
// 异步操作性能监控
final result = await logger.measurePerformance('操作名称', () async {
  // 异步操作
});

// 同步操作性能监控
final syncResult = logger.measureSyncPerformance('操作名称', () {
  // 同步操作
  return someValue;
});

// 输出性能报告
logger.logPerformanceMetrics();
```

### 错误处理

```dart
final errorReporter = ErrorReporter(
  onError: (error, stackTrace) {
    // 处理错误
  },
);

final logger = Logger(
  errorReporter: errorReporter,
);
```

## 高级特性

### 自定义中间件

```dart
class CustomMiddleware extends AbstractLogMiddleware {
  @override
  AbstractOutputer createOutputer() {
    // 实现自定义输出器
  }

  @override
  AbstractLogFormatter createFormatter() {
    // 实现自定义格式化器
  }

  @override
  AbstractLogFilter createFilter() {
    // 实现自定义过滤器
  }
}
```

### 存储监控

```dart
final storageMonitor = StorageMonitor(
  minimumFreeSpace: 100 * 1024 * 1024, // 100MB
);

final hasSpace = await storageMonitor.hasEnoughSpace('/path/to/logs');
```

## 最佳实践

1. **初始化时机**
   - 在应用程序启动时尽早初始化日志系统
   - 使用异常捕获确保初始化错误不会影响应用程序

2. **日志级别使用**
   - 开发环境使用 DEBUG 级别
   - 生产环境使用 INFO 级别
   - 关键错误使用 CRITICAL 或 FATAL 级别

3. **性能考虑**
   - 使用异步日志记录
   - 合理配置日志轮转大小
   - 启用压缩以节省存储空间

4. **安全性**
   - 避免记录敏感信息
   - 定期清理日志文件
   - 监控日志存储空间

## API 文档

完整的 API 文档请访问：[API 文档](https://pub.dev/documentation/logger_easier/latest/)

## 贡献指南

欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与项目开发。

## 许可证

本项目采用 MIT 许可证，详情请参见 [LICENSE](LICENSE) 文件。

---

如有问题或建议，欢迎提交 Issue 或 Pull Request。

[GitHub 仓库](https://github.com/jacklee1995/flutter_logger_easier)
