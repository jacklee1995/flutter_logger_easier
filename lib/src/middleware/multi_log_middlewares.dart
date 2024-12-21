import 'dart:async';
import '../core/log_record.dart';
import 'log_middlewares.dart';

/// TODO:多重日志处理，支持同时使用多个日志处理器
class MultiLogMiddleware {
  final List<LogMiddleware> _handlers;

  /// 构造函数，接受一个日志处理器列表
  MultiLogMiddleware(this._handlers);

  /// 处理单个日志记录
  Future<void> handle(LogRecord record) async {
    await Future.wait(_handlers.map((handler) => handler.handle(record)));
  }

  /// 关闭所有处理器
  Future<void> close() async {
    await Future.wait(_handlers.map((handler) => handler.close()));
  }

  /// 添加新的日志处理器
  void addHandler(LogMiddleware handler) {
    _handlers.add(handler);
  }

  /// 移除指定的日志处理器
  void removeHandler(LogMiddleware handler) {
    _handlers.remove(handler);
  }

  /// 获取当前的日志处理器列表
  List<LogMiddleware> get handlers => List.unmodifiable(_handlers);

  /// 清除所有日志处理器
  void clearHandlers() {
    _handlers.clear();
  }

  /// 获取日志处理器数量
  int get handlerCount => _handlers.length;

  /// 检查是否包含特定类型的日志处理器
  bool hasHandlerOfType<T extends LogMiddleware>() {
    return _handlers.any((handler) => handler is T);
  }

  /// 获取特定类型的日志处理器列表
  List<T> getHandlersOfType<T extends LogMiddleware>() {
    return _handlers.whereType<T>().toList();
  }

  /// 替换特定类型的日志处理器
  void replaceHandlerOfType<T extends LogMiddleware>(T newHandler) {
    final index = _handlers.indexWhere((handler) => handler is T);
    if (index != -1) {
      _handlers[index] = newHandler;
    } else {
      _handlers.add(newHandler);
    }
  }

  @override
  String toString() {
    return 'MultiLogMiddleware(handlers: $_handlers)';
  }
}
