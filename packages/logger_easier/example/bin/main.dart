import 'package:logger_easier/logger_easier.dart';

void main(List<String> arguments) {
  final logger = Logger();

  // 实例化一个控制台中间件
  final consoleMiddleware = ConsoleMiddleware();

  // 安装该中间件实例
  logger.use(consoleMiddleware);

  // 记录不同级别的日志
  logger.trace('这是一条追踪日志');
  logger.debug('这是一条调试日志');
  logger.info('这是一条信息日志');
  logger.warn('这是一条警告日志');
  logger.error('这是一条错误日志');
  logger.critical('这是一条严重错误日志');
  logger.fatal('这是一条致命错误日志');
}
