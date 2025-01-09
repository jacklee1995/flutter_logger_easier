import '../core/log_level.dart' show LogLevel;
import '../utils/ansi_color.dart' show AnsiColor;

/// 颜色支持的混入，提供默认的颜色实现
mixin ColorSupportMixin {
  String getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return AnsiColor.cyan;
      case LogLevel.debug:
        return AnsiColor.blue;
      case LogLevel.info:
        return AnsiColor.green;
      case LogLevel.warn:
        return AnsiColor.yellow;
      case LogLevel.error:
        return AnsiColor.brightRed;
      case LogLevel.critical:
        return AnsiColor.pink;
      case LogLevel.fatal:
        return AnsiColor.magenta;
    }
  }

  String getLevelFgColor(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return AnsiColor.white;
      case LogLevel.debug:
        return AnsiColor.white;
      case LogLevel.info:
        return AnsiColor.black;
      case LogLevel.warn:
        return AnsiColor.black;
      case LogLevel.error:
        return AnsiColor.white;
      case LogLevel.critical:
        return AnsiColor.white;
      case LogLevel.fatal:
        return AnsiColor.white;
    }
  }

  String getLevelBgColor(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return AnsiColor.bgCyan;
      case LogLevel.debug:
        return AnsiColor.bgBlue;
      case LogLevel.info:
        return AnsiColor.bgGreen;
      case LogLevel.warn:
        return AnsiColor.bgYellow;
      case LogLevel.error:
        return AnsiColor.bgRed;
      case LogLevel.critical:
        return AnsiColor.bgMagenta;
      case LogLevel.fatal:
        return AnsiColor.bgBrightRed;
    }
  }
}
