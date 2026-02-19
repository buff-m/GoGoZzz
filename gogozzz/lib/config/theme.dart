import 'package:flutter/material.dart';

/// 应用主题配置
class AppTheme {
  AppTheme._();

  // 背景色
  static const Color backgroundDark = Color(0xFF0a0e1a);
  static const Color backgroundDarker = Color(0xFF0d1120);
  static const Color backgroundCard = Color(0xFF131929);
  static const Color backgroundCardLight = Color(0xFF1a2235);

  // 打卡按钮背景渐变
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1a2235), Color(0xFF0d1120)],
  );

  // 已打卡状态背景渐变（绿色系）
  static const LinearGradient buttonGradientChecked = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0d2818), Color(0xFF061410)],
  );

  // 边框色
  static const Color borderColor = Color(0xFF1e2d45);
  static const Color borderColorLight = Color(0xFF243350);
  static const Color disabledColor = Color(0xFF2a3347);

  // 文字颜色
  static const Color textPrimary = Color(0xFFe8edf5);
  static const Color textSecondary = Color(0xFF7a8ba8);
  static const Color textTertiary = Color(0xFF4a5a72);

  /// 七级打卡颜色
  static const List<Color> levelColors = [
    Color(0xFF15803d), // 1: 深绿
    Color(0xFF22c55e), // 2: 绿色
    Color(0xFF4ade80), // 3: 浅绿
    Color(0xFFa3e635), // 4: 黄绿色 (正常)
    Color(0xFFeab308), // 5: 黄色
    Color(0xFFf97316), // 6: 橙色
    Color(0xFFef4444), // 7: 红色 (熬夜)
  ];

  // 未打卡颜色
  static const Color notClockedColor = Color(0xFFFFFFFF);

  /// 获取对应级别的颜色
  static Color getLevelColor(int level) {
    if (level < 1 || level > 7) return notClockedColor;
    return levelColors[level - 1];
  }

  /// 深色主题数据
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: levelColors[3],
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFa3e635),
        surface: backgroundDark,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundDarker,
        selectedItemColor: textPrimary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: textTertiary, fontSize: 12),
      ),
    );
  }
}
