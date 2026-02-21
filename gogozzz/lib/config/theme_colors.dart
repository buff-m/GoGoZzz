import 'package:flutter/material.dart';

/// 主题颜色抽象接口
abstract class AppThemeColors {
  // 背景色
  Color get background;
  Color get backgroundSecondary;
  Color get backgroundCard;
  Color get backgroundCardLight;

  // 边框色
  Color get border;
  Color get borderLight;
  Color get disabled;

  // 文字颜色
  Color get textPrimary;
  Color get textSecondary;
  Color get textTertiary;

  // 按钮渐变
  LinearGradient get buttonGradient;
  LinearGradient get buttonGradientChecked;

  // 7级颜色（共用）
  static const List<Color> levelColors = [
    Color(0xFF15803d), // 1: 深绿
    Color(0xFF22c55e), // 2: 绿色
    Color(0xFF4ade80), // 3: 浅绿
    Color(0xFFa3e635), // 4: 黄绿色 (正常)
    Color(0xFFeab308), // 5: 黄色
    Color(0xFFf97316), // 6: 橙色
    Color(0xFFef4444), // 7: 红色 (熬夜)
  ];

  /// 获取对应级别的颜色
  static Color getLevelColor(int level) {
    if (level < 1 || level > 7) return notClockedColor;
    return levelColors[level - 1];
  }

  /// 未打卡颜色
  static const Color notClockedColor = Color(0xFFFFFFFF);
}

/// 暗色主题颜色
class DarkThemeColors implements AppThemeColors {
  const DarkThemeColors();

  @override
  Color get background => const Color(0xFF0a0e1a);

  @override
  Color get backgroundSecondary => const Color(0xFF0d1120);

  @override
  Color get backgroundCard => const Color(0xFF131929);

  @override
  Color get backgroundCardLight => const Color(0xFF1a2235);

  @override
  Color get border => const Color(0xFF1e2d45);

  @override
  Color get borderLight => const Color(0xFF243350);

  @override
  Color get disabled => const Color(0xFF2a3347);

  @override
  Color get textPrimary => const Color(0xFFe8edf5);

  @override
  Color get textSecondary => const Color(0xFF7a8ba8);

  @override
  Color get textTertiary => const Color(0xFF4a5a72);

  @override
  LinearGradient get buttonGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1a2235), Color(0xFF0d1120)],
      );

  @override
  LinearGradient get buttonGradientChecked => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0d2818), Color(0xFF061410)],
      );
}

/// 亮色主题颜色
class LightThemeColors implements AppThemeColors {
  const LightThemeColors();

  @override
  Color get background => const Color(0xFFfaf8f5);

  @override
  Color get backgroundSecondary => const Color(0xfff5f2ed);

  @override
  Color get backgroundCard => const Color(0xffffffff);

  @override
  Color get backgroundCardLight => const Color(0xfff8f6f2);

  @override
  Color get border => const Color(0xffe8e4dd);

  @override
  Color get borderLight => const Color(0xffd9d4ca);

  @override
  Color get disabled => const Color(0xffc8c2b8);

  @override
  Color get textPrimary => const Color(0xff2d2a26);

  @override
  Color get textSecondary => const Color(0xff6b645a);

  @override
  Color get textTertiary => const Color(0xff9c948a);

  @override
  LinearGradient get buttonGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xfff8f6f2), Color(0xfff0ede7)],
      );

  @override
  LinearGradient get buttonGradientChecked => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xffe8f5e9), Color(0xffc8e6c9)],
      );
}
