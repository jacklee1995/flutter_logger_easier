import 'interfaces/compression_handler.dart';
import 'interfaces/rotate_strategy.dart';

/// 日志轮转配置类
///
/// 该类用于配置日志轮转管理器 [LogRotateManager] 的各项参数设置。它包括轮转策略、压缩处理器、轮转检查间隔、异步轮转开关等配置项。
///
/// 配置项包括：
/// - 轮转策略 [strategy]：选择日志轮转的策略（如基于大小或时间的轮转策略）。
/// - 压缩处理器 [compressionHandler]：配置日志压缩处理器（可选）。
/// - 延迟压缩 [delayCompress]：控制日志是否在轮转后立即压缩，默认为 `true`（延迟压缩）。
/// - 检查间隔 [checkInterval]：日志轮转检查的时间间隔，默认为每 5 分钟检查一次。
/// - 异步轮转 [enableAsyncRotation]：是否启用异步轮转，默认为 `true`（启用）。
/// - 轮转队列大小 [rotationQueueSize]：设置异步队列的大小，控制并发轮转的数量，默认为 100。
/// - 存储监控 [enableStorageMonitoring]：是否启用存储空间监控，确保日志文件轮转时有足够的空间，默认为 `true`。
/// - 最低剩余空间 [minimumFreeSpace]：存储空间的最小剩余要求，默认为 100MB。
/// - 是否在文件名中包含日期 [includeDate]：是否在文件名中包含日期。
/// - 是否在文件名中包含具体时间 [includeTime]：是否在文件名中包含具体时间。
/// - 日期时间分隔符 [separator]：日期时间分隔符。
///
/// 参数：
/// - [strategy] 日志轮转策略。必需的参数。
/// - [compressionHandler] 压缩处理器，默认为 `null`（不压缩）。
/// - [delayCompress] 是否延迟压缩，默认为 `true`。
/// - [checkInterval] 日志轮转检查的间隔时间，默认为每 5 分钟检查一次。
/// - [enableAsyncRotation] 是否启用异步轮转，默认为 `true`。
/// - [rotationQueueSize] 异步轮转队列的最大大小，默认为 100。
/// - [enableStorageMonitoring] 是否启用存储监控，默认为 `true`。
/// - [minimumFreeSpace] 存储空间的最小剩余要求，默认为 100MB。
/// - [includeDate] 是否在文件名中包含日期。
/// - [includeTime] 是否在文件名中包含具体时间。
/// - [separator] 日期时间分隔符。
/// - [archiveDir] 归档目录。
class LogRotateConfig {
  /// 日志轮转策略
  ///
  /// 轮转策略决定了日志轮转的条件和行为。例如：大小限制、时间间隔等。
  final RotateStrategy strategy;

  /// 压缩处理器
  ///
  /// 可选的压缩处理器，用于在日志轮转后进行压缩。默认为 `null`，不进行压缩。
  final CompressionHandler? compressionHandler;

  /// 是否延迟压缩
  ///
  /// 如果为 `true`，则压缩操作将延迟到轮转后异步执行；如果为 `false`，则会在轮转时立即执行压缩。默认为 `true`。
  final bool delayCompress;

  /// 日志轮转检查间隔
  ///
  /// 配置日志轮转管理器检查日志轮转条件的时间间隔。默认为每 5 分钟检查一次。
  final Duration checkInterval;

  /// 是否启用异步轮转
  ///
  /// 如果为 `true`，则日志轮转将在异步队列中执行，允许多个日志文件并行轮转。默认为 `true`。
  final bool enableAsyncRotation;

  /// 轮转队列大小
  ///
  /// 设置异步轮转队列的最大大小，控制并发轮转的数量。默认为 100。
  final int rotationQueueSize;

  /// 是否启用存储监控
  ///
  /// 如果为 `true`，则启用存储空间监控，确保在轮转时有足够的磁盘空间。如果剩余空间低于 [minimumFreeSpace]，则会停止日志轮转。
  /// 默认为 `true`。
  final bool enableStorageMonitoring;

  /// 最低剩余空间
  ///
  /// 配置存储空间的最小剩余要求，单位为字节。默认为 100MB。
  final int minimumFreeSpace;

  /// 是否在文件名中包含日期
  final bool includeDate;

  /// 是否在文件名中包含具体时间
  final bool includeTime;

  /// 日期时间分隔符
  final String separator;

  /// 归档目录
  final String? archiveDir;

  /// 构造函数
  ///
  /// 创建一个日志轮转配置对象，允许根据需要自定义日志轮转行为。
  ///
  /// 参数：
  /// - [strategy] 必选，指定日志轮转策略。
  /// - [compressionHandler] 可选，指定压缩处理器，默认为 `null`。
  /// - [delayCompress] 可选，是否延迟压缩，默认为 `true`。
  /// - [checkInterval] 可选，指定检查间隔，默认为 5 分钟。
  /// - [enableAsyncRotation] 可选，是否启用异步轮转，默认为 `true`。
  /// - [rotationQueueSize] 可选，异步队列大小，默认为 100。
  /// - [enableStorageMonitoring] 可选，是否启用存储监控，默认为 `true`。
  /// - [minimumFreeSpace] 可选，指定最低剩余空间，默认为 100MB。
  /// - [includeDate] 可选，是否在文件名中包含日期。
  /// - [includeTime] 可选，是否在文件名中包含具体时间。
  /// - [separator] 可选，日期时间分隔符。
  /// - [archiveDir] 可选，指定归档目录。
  LogRotateConfig({
    required this.strategy,
    this.compressionHandler,
    this.delayCompress = true,
    this.checkInterval = const Duration(minutes: 5),
    this.enableAsyncRotation = true,
    this.rotationQueueSize = 100,
    this.enableStorageMonitoring = true,
    this.minimumFreeSpace = 100 * 1024 * 1024, // 100MB
    this.includeDate = true,
    this.includeTime = false,
    this.separator = '_',
    this.archiveDir,
  });
}
