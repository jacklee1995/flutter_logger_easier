# Logger Easier

一个为 Dart 和 Flutter 应用程序设计的现代化日志管理解决方案。提供了丰富的功能和灵活的配置选项，让日志管理变得更简单。

## 目录

- [Logger Easier](#logger-easier)
  - [目录](#目录)
  - [项目结构](#项目结构)
  - [包说明](#包说明)
    - [logger\_easier](#logger_easier)
    - [json\_middleware\_for\_logger\_easier](#json_middleware_for_logger_easier)
  - [快速开始](#快速开始)
  - [贡献指南](#贡献指南)
  - [许可证](#许可证)

## 项目结构

```
logger_easier/
├── packages/
│   ├── logger_easier/                # 核心日志包
│   └── json_middleware_for_logger_easier/  # JSON中间件包
└── example/                          # 示例项目
```

## 包说明

### [logger_easier](packages/logger_easier/README_CN.md)

核心日志管理包，提供：

- 多级日志管理（TRACE、DEBUG、INFO、WARN、ERROR、CRITICAL、FATAL）
- 强大的日志轮转（基于大小/时间的轮转策略）
- 丰富的输出选项（控制台/文件输出，支持彩色显示）
- 高级格式化功能
- 性能监控
- 错误处理

### [json_middleware_for_logger_easier](packages/json_middleware_for_logger_easier/README_CN.md)

JSON格式日志中间件，提供：

- JSON格式日志输出
- 结构化日志数据
- 自定义字段映射
- 灵活的序列化选项

## 快速开始

1. 添加依赖

```yaml
dependencies:
  logger_easier: ^0.0.3
  json_middleware_for_logger_easier: ^0.0.1  # 可选
```

2. 基础用法

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

3. 使用 JSON 中间件（可选）

```dart
import 'package:json_middleware_for_logger_easier/json_middleware_for_logger_easier.dart';

final jsonMiddleware = JsonMiddleware(
  prettyPrint: true,
  includeStackTrace: true,
);

logger.use(jsonMiddleware);
```

更多详细用法请参考各个包的文档：
- [logger_easier 详细文档](packages/logger_easier/README_CN.md)
- [json_middleware_for_logger_easier 详细文档](packages/json_middleware_for_logger_easier/README_CN.md)

## 贡献指南

我们欢迎任何形式的贡献，包括但不限于：

- 提交问题和建议
- 改进文档
- 提交代码改进
- 添加新功能
- 修复 bug

请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详细的贡献指南。

## 许可证

本项目采用 MIT 许可证，详情请参见 [LICENSE](LICENSE) 文件。

---

如有问题或建议，欢迎提交 Issue 或 Pull Request。

[GitHub 仓库](https://github.com/jacklee1995/flutter_logger_easier)

