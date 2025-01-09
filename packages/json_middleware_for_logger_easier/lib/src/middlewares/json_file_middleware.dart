import 'package:logger_easier/logger_easier.dart';
import '../formatters/json_formatter.dart';
import '../outputers/json_outputer.dart';
import '../outputers/json_outputer_config.dart';

class JsonFileMiddleware extends AbstractLogMiddleware {
  final JsonOutputerConfig config;
  JsonFileMiddleware({
    required this.config,
    AbstractLogFormatter? formatter,
    AbstractLogFilter? filter,
  }) {
    outputer = createOutputer();
    formatter = formatter ?? createFormatter();
    filter = filter ?? createFilter();
  }

  @override
  AbstractOutputer createOutputer() {
    return JsonOutputer(config: config);
  }

  @override
  AbstractLogFormatter createFormatter() {
    // 在这里返回默认的 JSON 格式化器
    // 你需要在 `lib/src/formatter/json_formatter.dart` 中定义 `JsonFormatter` 类
    return JsonFormatter();
  }

  @override
  AbstractLogFilter createFilter() {
    // 在这里返回默认的日志过滤器
    // 你可以使用 logger_easier 包提供的 `LevelFilter`,或者自定义一个过滤器
    return LevelFilter(LogLevel.debug);
  }

  @override
  Future<void> handle(LogRecord record) async {
    if (!filter.shouldLog(record)) {
      return;
    }

    final formattedRecord = record.copyWith(
      message: formatter.format(record),
    );
    outputer.printf(formattedRecord);
  }

  @override
  Future<void> close() async {
    await outputer.close();
  }
}
