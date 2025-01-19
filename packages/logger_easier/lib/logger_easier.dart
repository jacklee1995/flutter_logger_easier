library;

// 核心
export 'src/core/logger_easier_base.dart';
export 'src/core/log_level.dart';
export 'src/core/log_record.dart';

// 接口
export 'src/interfaces/abstract_outputer.dart';
export 'src/interfaces/abstract_log_formatter.dart';
export 'src/interfaces/abstract_log_filter.dart';
export 'src/interfaces/abstract_log_middleware.dart';

// 日志过滤器
export 'src/expands/filters/level_filter.dart';
export 'src/expands/filters/log_filters.dart';

// 日志格式化器
export 'src/expands/formatters/inline_formatter.dart';

// 日志输出器
export 'src/expands/outputer/console_outputer.dart';
export 'src/expands/outputer/file_outputer.dart';

// 日志中间件
export 'src/expands/middlewares/file_middleware.dart';
export 'src/expands/middlewares/console_middleware.dart';

// 默认颜色支持
export './src/mixins/color_support.dart';

// 日志轮转器
export 'src/log_rotate/rotate_config.dart';
export 'src/log_rotate/rotate_manager.dart';
export 'src/log_rotate/strategies/size_based_strategy.dart';
export 'src/log_rotate/strategies/time_based_strategy.dart';
export 'src/log_rotate/compression/gzip_handler.dart';

// 工具
export 'src/utils/ansi_color.dart';
export 'src/utils/log_utils.dart';

// TODO: 错误报告
export './src/error_reporting/crash_analytics.dart';
export './src/error_reporting/error_reporter.dart';

// TODO: 性能监控
export './src/performance/performance_metrics.dart';
export './src/performance/performance_monitor.dart';

// TODO: 存储
export './src/storage/log_storage.dart';
