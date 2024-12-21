# Logger Easier

## 🌟 项目简介

Logger Easier 是一个为 Dart 和 Flutter 应用程序量身定制的现代化日志管理解决方案。它提供了一个高度灵活、功能丰富的日志记录系统，旨在简化开发者的日志管理工作，同时提供一定的定制能力。

![alt text](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/example.png)

## ✨ 核心特性

1. 多级日志管理
   - 支持 7 个日志级别：Trace, Debug, Info, Warn, Error, Critical, Fatal
   - 细粒度的日志级别控制
   - 可配置的最小日志记录级别

2. 灵活的日志输出
   - 控制台输出（支持彩色日志）
   - 文件日志记录
   - 自定义输出目标
   - 日志文件轮转和压缩

3. 高级日志格式化
   - 可定制的日志格式
   - 支持多种日志格式模板
   - 丰富的日志记录元数据（时间戳、来源、错误信息等）

4. 性能监控
   - 内置性能度量方法
   - 异步和同步操作性能追踪
   - 性能指标自动记录和报告

5. 错误处理
   - 自动错误报告
   - 堆栈跟踪记录
   - 可插拔的错误报告器

6. 单例模式
   - 全局统一的日志管理
   - 简单的初始化和使用

7. 可扩展性
   - 支持自定义日志处理器
   - 可插拔的组件（打印器、输出器、格式化器、过滤器）

## 📦 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  logger_easier: ^0.0.1
```

运行 `dart pub get` 或 `flutter pub get` 安装依赖。

## 🚀 快速开始

### 基本使用

```dart
import 'package:logger_easier/logger_easier.dart';

void main() {
  // 创建默认日志实例
  final logger = Logger();

  // 记录不同级别的日志
  logger.debug('调试信息');
  logger.info('普通信息');
  logger.warn('警告信息');
  logger.error('错误信息', error: Exception('示例错误'));
}
```

### 文件日志配置

```dart
final logger = Logger(
  logDirectory: '/path/to/logs',
  baseFileName: 'app.log',
  maxFileSize: 10 * 1024 * 1024, // 10MB
  maxBackupIndex: 5,
  compress: true,
);
```

### 性能度量

```dart
// 异步性能度量
final result = await logger.measurePerformance('complex_operation', () async {
  return await complexOperation();
});

// 同步性能度量
final syncResult = logger.measureSyncPerformance('simple_operation', () {
  return simpleOperation();
});
```

### 自定义日志处理

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

## 🌈 日志级别

Logger Easier 支持 7 个日志级别，按严重程度递增：

1. `trace`：最详细的跟踪信息，用于细粒度诊断
2. `debug`：调试信息，开发和诊断使用
3. `info`：常规信息，应用程序重要事件
4. `warn`：警告信息，潜在的问题或异常情况
5. `error`：错误信息，导致功能异常的问题
6. `critical`：关键错误，严重影响系统运行
7. `fatal`：致命错误，系统无法继续运行

## 📝 最佳实践

1. 在应用程序启动时初始化日志
2. 使用适当的日志级别
3. 在生产环境中禁用详细日志
4. 定期清理和归档日志文件
5. 保护敏感信息，避免在日志中记录敏感数据

## 🔒 许可证

本项目采用 MIT 许可证，详情请参见 [LICENSE](LICENSE) 文件。

## 🤝 贡献指南

欢迎通过以下方式参与项目：

- 提交 Issues
- 发起 Pull Requests
- 改进文档
- 分享使用经验

请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详细的贡献指南。

## 📞 支持与联系

- GitHub Issues: [提交问题](https://github.com/jacklee1995/flutter_logger_easier/issues)
- 电子邮件: [291148484@163.com](mailto:291148484@163.com)

## 🌍 多语言支持

- [English](README.md)
- [中文](README_CN.md)

---

**注意**：Logger Easier 正在持续开发中，API 可能会有所变化。建议关注版本更新。此文件更新可能稍后于代码，请务必参考example示例项目使用。
