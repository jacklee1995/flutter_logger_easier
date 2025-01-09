/// ANSI颜色和样式控制类，用于控制台输出的丰富格式化
class AnsiColor {
  /// 重置所有样式
  static const String reset = '\x1B[0m';

  /// 前景色 - 基本颜色
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';

  /// 前景色 - 亮色
  static const String brightBlack = '\x1B[90m';
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
  static const String brightBlue = '\x1B[94m';
  static const String brightMagenta = '\x1B[95m';
  static const String brightCyan = '\x1B[96m';
  static const String brightWhite = '\x1B[97m';

  /// 背景色 - 基本颜色
  static const String bgBlack = '\x1B[40m';
  static const String bgRed = '\x1B[41m';
  static const String bgGreen = '\x1B[42m';
  static const String bgYellow = '\x1B[43m';
  static const String bgBlue = '\x1B[44m';
  static const String bgMagenta = '\x1B[45m';
  static const String bgCyan = '\x1B[46m';
  static const String bgWhite = '\x1B[47m';

  /// 背景色 - 亮色
  static const String bgBrightBlack = '\x1B[100m';
  static const String bgBrightRed = '\x1B[101m';
  static const String bgBrightGreen = '\x1B[102m';
  static const String bgBrightYellow = '\x1B[103m';
  static const String bgBrightBlue = '\x1B[104m';
  static const String bgBrightMagenta = '\x1B[105m';
  static const String bgBrightCyan = '\x1B[106m';
  static const String bgBrightWhite = '\x1B[107m';

  /// 额外的颜色 - 256色
  static const String orange = '\x1B[38;5;208m';
  static const String purple = '\x1B[38;5;129m';
  static const String pink = '\x1B[38;5;199m';
  static const String lime = '\x1B[38;5;118m';
  static const String teal = '\x1B[38;5;30m';
  static const String lavender = '\x1B[38;5;183m';
  static const String coral = '\x1B[38;5;209m';
  static const String skyBlue = '\x1B[38;5;45m';
  static const String salmon = '\x1B[38;5;209m';
  static const String olive = '\x1B[38;5;58m';

  /// 额外的背景色 - 256色
  static const String bgOrange = '\x1B[48;5;208m';
  static const String bgPurple = '\x1B[48;5;129m';
  static const String bgPink = '\x1B[48;5;199m';

  /// 样式
  static const String bold = '\x1B[1m';
  static const String dim = '\x1B[2m';
  static const String italic = '\x1B[3m';
  static const String underline = '\x1B[4m';
  static const String blink = '\x1B[5m';
  static const String reverse = '\x1B[7m';
  static const String hidden = '\x1B[8m';
  static const String strikethrough = '\x1B[9m';

  /// 将文本用指定的颜色包裹
  ///
  /// [text] 要着色的文本
  /// [color] ANSI颜色代码
  /// [style] 可选的样式
  static String wrap(String text, String color, {String? style}) {
    // 如果同时有样式和颜色
    if (style != null) {
      return '$style$color$text$reset';
    }

    // 仅有颜色
    return '$color$text$reset';
  }

  /// 将文本用指定的颜色和背景色包裹
  ///
  /// [text] 要着色的文本
  /// [fgColor] 前景色
  /// [bgColor] 背景色
  /// [style] 可选的样式
  static String wrapWithBackground(
    String text,
    String fgColor,
    String bgColor, {
    String? style,
  }) {
    if (style != null) {
      return '$style$fgColor$bgColor$text$reset';
    }
    return '$fgColor$bgColor$text$reset';
  }

  /// 多行文本着色，主要是处理如stack这种多行文本问题
  ///
  /// [text] 要着色的多行文本
  /// [color] 颜色
  /// [style] 可选样式
  static String wrapMultiline(
    String text,
    String color, {
    String? style,
  }) {
    final lines = text.split('\n');
    final coloredLines = lines.map((line) => wrap(line, color, style: style));
    return coloredLines.join('\n');
  }

  /// 为不同行应用不同的颜色
  ///
  /// [text] 要着色的多行文本
  /// [colors] 每行对应的颜色列表
  /// [styles] 可选的样式列表
  static String wrapMultilineWithDifferentColors(
    String text,
    List<String> colors, {
    List<String>? styles,
  }) {
    final lines = text.split('\n');
    final coloredLines = lines.mapIndexed((index, line) {
      final color = colors[index % colors.length];
      final style = styles != null ? styles[index % styles.length] : null;
      return wrap(line, color, style: style);
    }).toList();
    return coloredLines.join('\n');
  }
}

/// 为 Iterable 添加 mapIndexed 扩展
extension IndexedIterable<E> on Iterable<E> {
  /// 带索引的 map 操作
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) {
    return Iterable.generate(length, (index) => f(index, elementAt(index)));
  }
}
