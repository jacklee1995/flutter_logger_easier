import 'package:logger_easier/logger_easier.dart';
import '../formatters/json_formatter.dart';
import '../formatters/json_formatter_config.dart';
import '../outputers/json_console_printer.dart';

class JsonPrintMiddleware extends AbstractLogMiddleware {
  JsonPrintMiddleware({
    AbstractLogFilter? filter,
    JsonFormatterConfig? config,
    OutputFunction? outputFunction,
  }) {
    // TODO:如果使用 debugPrint，则禁用颜色
    // final useColor = outputFunction == null || identical(outputFunction, print);

    outputer = JsonConsolePrinter(
      outputFunction: outputFunction,
      // useColor: useColor, // 根据输出函数类型决定是否使用颜色
    );

    formatter = JsonFormatter(config: config ?? JsonFormatterConfig());
    this.filter = filter ?? LevelFilter(LogLevel.debug);
  }

  @override
  Future<void> handle(LogRecord record) async {
    if (!filter.shouldLog(record)) {
      return;
    }

    final jsonOutput = formatter.format(record);
    outputer.printf(LogRecord(
      record.level,
      jsonOutput,
      error: record.error,
      stackTrace: record.stackTrace,
    ));
  }

  @override
  Future<void> close() async {
    await outputer.close();
  }

  @override
  AbstractOutputer createOutputer() => JsonConsolePrinter();

  @override
  AbstractLogFormatter createFormatter() => JsonFormatter();

  @override
  AbstractLogFilter createFilter() => LevelFilter(LogLevel.debug);
}
