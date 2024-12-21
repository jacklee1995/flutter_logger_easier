import '../core/log_record.dart';
import '../interfaces/base_printer.dart';
import '../interfaces/log_formatter.dart';
import '../filters/log_filter.dart';

/// 日志处理器类
///
/// 负责处理单个日志记录的整个流程，包括过滤、格式化、打印和输出
class LogMiddleware {
  final BasePrinter printer;
  // final BaseOutput output;
  final LogFormatter formatter;
  final LogFilter filter;

  /// 构造函数
  ///
  /// [printer] 日志打印器
  /// [output] 日志输出器
  /// [formatter] 日志格式化器
  /// [filter] 日志过滤器
  LogMiddleware({
    required this.printer,
    // required this.output,
    required this.formatter,
    required this.filter,
  });

  /// 处理单个日志记录
  ///
  /// [record] 要处理的日志记录
  Future<void> handle(LogRecord record) async {
    if (!filter.shouldLog(record)) {
      return;
    }

    try {
      // 使用打印器处理日志记录
      printer.printf(record);
    } catch (e, stackTrace) {
      print('Error handling log record: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// 关闭处理器
  ///
  /// 这个方法应该被调用来清理任何资源，比如关闭文件或网络连接
  Future<void> close() async {
    await printer.close();
    // await output.close();
  }
}
