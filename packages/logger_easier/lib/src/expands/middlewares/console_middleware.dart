import '../../core/log_level.dart' show LogLevel;
import '../../core/log_record.dart' show LogRecord;
import '../../interfaces/abstract_log_middleware.dart'
    show AbstractLogMiddleware;
import '../../interfaces/abstract_outputer.dart' show AbstractOutputer;
import '../../interfaces/abstract_log_filter.dart' show AbstractLogFilter;
import '../../interfaces/abstract_log_formatter.dart' show AbstractLogFormatter;
import '../formatters/base_formatter.dart' show BaseFormatter;
import '../outputer/console_outputer.dart' show ConsolePrinter;
import '../filters/level_filter.dart' show LevelFilter;

class ConsoleMiddleware extends AbstractLogMiddleware {
  ConsoleMiddleware({
    AbstractOutputer? outputer,
    AbstractLogFormatter? formatter,
    AbstractLogFilter? filter,
  }) {
    outputer = outputer ?? createOutputer();
    formatter = formatter ?? createFormatter();
    filter = filter ?? createFilter();
  }

  @override
  AbstractOutputer createOutputer() {
    return ConsolePrinter(
      useColor: true,
      maxLineLength: 160,
    );
  }

  @override
  AbstractLogFormatter createFormatter() {
    return BaseFormatter();
  }

  @override
  AbstractLogFilter createFilter() {
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
