# 更新日志

## 0.0.3+1（2025-01-16）

### 修复

- 一些场景下未更新日志大小异常；

## 0.0.3 (2025-01-09)

### 新特性
- 新增日志轮转功能
  - 支持基于大小的轮转策略
  - 支持基于时间的轮转策略
  - 支持日志压缩
  - 添加存储空间监控
- 新增性能监控功能
  - 支持异步操作性能追踪
  - 支持同步操作性能追踪
  - 添加性能指标统计
- 新增错误处理功能
  - 全局错误捕获
  - 错误分析和报告
  - 崩溃日志记录

### 改进
- 重构日志中间件系统，提供更灵活的扩展性
- 优化日志格式化器，支持更多自定义选项
- 改进控制台输出，支持更丰富的颜色显示
- 增强异步日志处理能力
- 完善文档和示例代码

### 修复
- 修复日志文件写入时的并发问题
- 修复日志轮转时可能的文件锁定问题
- 修复控制台颜色在某些终端下的显示问题

## 0.0.2 (2024-12-27)

### 新特性
- 中间版本，不在pub上发布
- 添加基础的日志中间件支持
- 实现控制台和文件输出
- 添加日志级别过滤
- 添加基础格式化功能

### 改进
- 采用melos管理包，便于后续集中提供更多的中间件
- 在melos中引入fvm管理版本
- 移除一些不用的模块，简化包结构
- 将日志中间件的方式改为通过`use()`方法按照顺序添加
- 改进API设计，提供更友好的接口

### 修复
- 修复日志文件创建权限问题
- 修复日志级别过滤逻辑错误

## 0.0.1 (2025-12-22)

### 初始版本
- 实现基础日志功能
- 支持多个日志级别
- 基础的控制台输出
- 简单的文件日志记录
