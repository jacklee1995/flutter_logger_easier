import '../core/log_record.dart' show LogRecord;
import 'abstract_outputer.dart' show AbstractOutputer;
import 'abstract_log_filter.dart' show AbstractLogFilter;
import 'abstract_log_formatter.dart' show AbstractLogFormatter;

/// 日志中间件的抽象基类
///
/// 所有具体的日志中间件实现都应该继承自这个类
abstract class AbstractLogMiddleware {
  /// 日志输出器
  ///
  /// 这个字段应该在中间件的构造函数中初始化
  late AbstractOutputer outputer;

  /// 日志格式化器
  ///
  /// 这个字段应该在中间件的构造函数中初始化
  late AbstractLogFormatter formatter;

  /// 日志过滤器
  ///
  /// 这个字段应该在中间件的构造函数中初始化
  late AbstractLogFilter filter;

  AbstractLogMiddleware({
    AbstractOutputer? outputer,
    AbstractLogFormatter? formatter,
    AbstractLogFilter? filter,
  }) {
    this.formatter = formatter ?? createFormatter();
    this.filter = filter ?? createFilter();
    this.outputer = outputer ?? createOutputer();
  }

  /// 创建一个日志输出器
  ///
  /// 这个方法应该返回一个 [AbstractOutputer] 的实例,用于将日志记录输出到特定的目标,
  /// 如控制台、文件或网络。
  AbstractOutputer createOutputer();

  /// 创建一个日志格式化器
  ///
  /// 这个方法应该返回一个 [AbstractLogFormatter] 的实例,用于将日志记录格式化为特定的字符串表示。
  AbstractLogFormatter createFormatter();

  /// 创建一个日志过滤器
  ///
  /// 这个方法应该返回一个 [AbstractLogFilter] 的实例,用于决定是否应该记录特定的日志记录。
  AbstractLogFilter createFilter();

  /// 处理一条日志记录
  ///
  /// 这个方法接受一个 [LogRecord] 对象,表示要处理的日志记录。中间件应该使用它的
  /// [AbstractLogFilter]、[AbstractLogFormatter] 和 [AbstractOutputer] 来过滤、格式化和输出日志记录。
  ///
  /// 返回一个 [Future],表示处理操作的完成。
  Future<void> handle(LogRecord record);

  /// 关闭中间件
  ///
  /// 这个方法应该清理中间件使用的任何资源,如打开的文件或网络连接。
  ///
  /// 返回一个 [Future],表示关闭操作的完成。
  Future<void> close();
}
