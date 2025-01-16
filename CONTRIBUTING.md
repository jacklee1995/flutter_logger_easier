# 如何贡献

## 获取包

可以通过从Github、Gitee（中国大陆地区）获取包。

### Github

```bash
git clone https://github.com/jacklee1995/flutter_logger_easier
```

### Gitee

```bash
git clone https://gitee.com/jacklee1995/flutter_logger_easier.git
```

目前Gitee仅作为备份，不处理PR。

## 准备工作

本项目使用多包管理和Flutter版本管理，需要先全局激活fvm包管理工具，然后在项目中使用合适的Flutter版本，比如：

```bash
fvm use 3.24.5
```

接着项目提靴：

```bash
melos bootstrap
# 简写：
melos bs
```

## 核心包贡献

核心包指的是packages/logger_easier项目。

## 中间件贡献

中间件可以作为独立的包实现，通过`use()`方法为Logger安装。

## 压缩器贡献

实际上，日志旋转功能模块实际上可以完全独立，不过考虑使用方便，目前放在核心包作为其中一部分。压缩器指的是日志旋转模块中实现`CompressionHandler`接口的具体类。主要需要实现两个方法，即压缩算法（compress方法）和与压缩算法对应的解压算法（decompress方法）。此外还需要通过实现`compressedExtension`这个读取器的值来指定压缩包的后缀（如`.gz`）。