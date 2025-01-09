import '../../core/log_level.dart' show LogLevel;
import '../../core/log_record.dart' show LogRecord;
import '../../interfaces/abstract_outputer.dart' show AbstractOutputer;
import '../../interfaces/abstract_log_filter.dart' show AbstractLogFilter;
import '../../interfaces/abstract_log_formatter.dart' show AbstractLogFormatter;
import '../../interfaces/abstract_log_middleware.dart'
    show AbstractLogMiddleware;
import '../formatters/base_formatter.dart' show BaseFormatter;
import '../filters/level_filter.dart' show LevelFilter;
import '../outputer/file_outputer.dart' show FilePrinter;

class FileMiddleware extends AbstractLogMiddleware {
  FileMiddleware({
    AbstractLogFormatter? formatter,
    AbstractLogFilter? filter,
    required this.logDirectory,
    required this.baseFileName,
    this.maxFileSize = 1024 * 1024,
    this.maxBackupIndex = 5,
    this.compress = false,
  }) {
    outputer = createOutputer();
    formatter = formatter ?? createFormatter();
    filter = filter ?? createFilter();
  }

  final String logDirectory;
  final String baseFileName;
  final int maxFileSize;
  final int maxBackupIndex;
  final bool compress;

  @override
  AbstractOutputer createOutputer() {
    return FilePrinter(
      logDirectory: logDirectory,
      baseFileName: baseFileName,
      maxFileSize: maxFileSize,
      maxBackupIndex: maxBackupIndex,
      compress: compress,
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
