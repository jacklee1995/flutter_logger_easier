# Logger Easier

[English](https://github.com/jacklee1995/flutter_logger_easier/blob/master/README.md)

一个为 Dart 和 Flutter 应用程序设计的现代化日志管理解决方案。提供了丰富的功能和灵活的配置选项,让日志管理变得更简单。

![logo](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/images/logo.png)

## 目录

- [Logger Easier](#logger-easier)
  - [目录](#目录)
  - [项目结构](#项目结构)
  - [核心包](#核心包)
  - [中间件包](#中间件包)
  - [快速开始](#快速开始)
  - [详细文档](#详细文档)
  - [贡献指南](#贡献指南)
  - [许可证](#许可证)

## 项目结构

Logger Easier 采用了多包管理的项目结构,使用 [Melos](https://github.com/invertase/melos) 进行管理和协调。这种结构允许我们将核心功能和可选功能分离到不同的包中,提高了模块化和可维护性。

```tree
logger_easier/
├── packages/
│   ├── logger_easier/                # 核心日志包
│   ├── json_middleware/              # JSON 中间件包
│   └── ...                           # 其他中间件包
├── example/                          # 示例项目
└── ...
```

## 核心包

- [**logger_easier**](packages/logger_easier/README_CN.md): 核心日志管理包,提供多级日志管理、日志轮转、丰富的输出选项、高级格式化、性能监控和错误处理等功能。

## 中间件包

Logger Easier 采用插件化架构,支持通过中间件扩展日志处理功能。目前已有以下中间件包:

- [**json_middleware**](packages/json_middleware/README_CN.md): 提供 JSON 格式的日志输出,支持结构化日志数据、自定义字段映射和灵活的序列化选项。
- 更多中间件包正在开发中,敬请期待...

## 快速开始

1. 添加依赖

```yaml
dependencies:
  logger_easier: ^latest_version
```

2. 初始化日志管理器

```dart
import 'package:logger_easier/logger_easier.dart';

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
```

3. 记录日志

```dart
logger.debug('这是一条调试日志');
logger.info('这是一条信息日志');
logger.error('这是一条错误日志', error: Exception('发生了一个错误'));
```

## 详细文档

- [logger_easier 详细文档](packages/logger_easier/README_CN.md)
- [json_middleware 详细文档](packages/json_middleware/README_CN.md)
- [API 参考](https://pub.dev/documentation/logger_easier/latest/)

## 贡献指南

我们欢迎任何形式的贡献,包括但不限于:

- 提交问题和建议
- 改进文档
- 提交代码改进
- 添加新功能
- 修复 bug

请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详细的贡献指南。

## 许可证

本项目采用 MIT 许可证,详情请参见 [LICENSE](LICENSE) 文件。

---

如有问题或建议,欢迎提交 Issue 或 Pull Request。

[GitHub 仓库](https://github.com/jacklee1995/flutter_logger_easier)

