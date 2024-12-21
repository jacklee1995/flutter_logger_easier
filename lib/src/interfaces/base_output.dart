import 'dart:async';

/// 日志输出的抽象基类
///
/// 所有具体的日志输出实现都应该继承自这个类
abstract class BaseOutput {
  /// 写入日志
  ///
  /// [log] 是格式化并准备好的日志字符串
  /// 返回一个 [Future] 表示写入操作的完成
  Future<void> write(String log);

  /// 刷新输出
  ///
  /// 确保所有缓冲的日志都被写入
  /// 返回一个 [Future] 表示刷新操作的完成
  Future<void> flush();

  /// 关闭输出
  ///
  /// 清理资源并关闭任何打开的连接或文件
  /// 返回一个 [Future] 表示关闭操作的完成
  Future<void> close();

  /// 检查输出是否已关闭
  bool get isClosed;

  /// 获取输出的名称或描述
  String get name;

  /// 获取输出的配置信息
  Map<String, dynamic> get config;

  /// 更新输出的配置
  ///
  /// [newConfig] 是新的配置信息
  /// 返回一个 [Future] 表示配置更新操作的完成
  Future<void> updateConfig(Map<String, dynamic> newConfig);

  /// 检查输出是否准备好接受日志
  ///
  /// 返回一个 [Future<bool>] 表示检查结果
  Future<bool> isReady();

  /// 重新打开已关闭的输出
  ///
  /// 返回一个 [Future] 表示重新打开操作的完成
  Future<void> reopen();

  /// 获取输出的统计信息
  ///
  /// 返回一个包含统计信息的 [Map]
  Map<String, dynamic> getStats();

  /// 重置输出的统计信息
  void resetStats();
}