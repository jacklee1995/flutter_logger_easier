 # Logger Easier

[中文](https://gitee.com/jacklee1995/flutter_logger_easier/blob/master/readme_CN.md)

A modern logging management solution designed for Dart and Flutter applications. It provides rich features and flexible configuration options, making logging management easier.

![logo](https://raw.githubusercontent.com/jacklee1995/flutter_logger_easier/refs/heads/master/images/logo.png)

## Table of Contents

- [Logger Easier](#logger-easier)
  - [Table of Contents](#table-of-contents)
  - [Project Structure](#project-structure)
  - [Core Package](#core-package)
  - [Middleware Packages](#middleware-packages)
  - [Quick Start](#quick-start)
  - [Detailed Documentation](#detailed-documentation)
  - [Contributing](#contributing)
  - [License](#license)

## Project Structure

Logger Easier adopts a multi-package project structure and is managed and coordinated using [Melos](https://github.com/invertase/melos). This structure allows us to separate core functionality and optional features into different packages, improving modularity and maintainability.

```tree
logger_easier/
├── packages/
│   ├── logger_easier/                # Core logging 
│   ├── json_middleware/              # JSON middleware 
│   └── ...                           # 其他中间件包
├── examples/                         # More example project
└── ...
```

## Core Package

- [**logger_easier**](packages/logger_easier/README.md): The core logging management package, providing multi-level logging, log rotation, rich output options, advanced formatting, performance monitoring, and error handling.

## Middleware Packages

Logger Easier adopts a plugin-based architecture and supports extending logging functionality through middleware. Currently, the following middleware packages are available:

- [**json_middleware**](packages/json_middleware/README.md): Provides JSON-formatted log output, supporting structured log data, custom field mapping, and flexible serialization options.
- More middleware packages are under development, stay tuned...

## Quick Start

1. Add dependency

```yaml
dependencies:
  logger_easier: ^latest_version
```

2. Initialize the logger

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

3. Log messages

```dart
logger.debug('This is a debug log');
logger.info('This is an info log');
logger.error('This is an error log', error: Exception('An error occurred'));
```

## Detailed Documentation

- [logger_easier detailed documentation](packages/logger_easier/README.md)
- [json_middleware detailed documentation](packages/json_middleware/README.md)
- [API Reference](https://pub.dev/documentation/logger_easier/latest/)

## Contributing

We welcome contributions of any kind, including but not limited to:

- Submitting issues and suggestions
- Improving documentation
- Submitting code improvements
- Adding new features
- Fixing bugs

Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

If you have any questions or suggestions, feel free to submit an Issue or Pull Request.

[GitHub Repository](https://github.com/jacklee1995/flutter_logger_easier)
