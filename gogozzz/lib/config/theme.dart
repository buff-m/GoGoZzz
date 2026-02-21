import 'package:flutter/material.dart';
import 'theme_colors.dart';

/// 应用主题配置
class AppTheme {
  AppTheme._();

  // 背景色（保持 const 向后兼容）
  static const Color backgroundDark = Color(0xFF0a0e1a);
  static const Color backgroundDarker = Color(0xFF0d1120);
  static const Color backgroundCard = Color(0xFF131929);
  static const Color backgroundCardLight = Color(0xFF1a2235);

  // 边框色（保持 const 向后兼容）
  static const Color borderColor = Color(0xFF1e2d45);
  static const Color borderColorLight = Color(0xFF243350);
  static const Color disabledColor = Color(0xFF2a3347);

  // 文字颜色（保持 const 向后兼容）
  static const Color textPrimary = Color(0xFFe8edf5);
  static const Color textSecondary = Color(0xFF7a8ba8);
  static const Color textTertiary = Color(0xFF4a5a72);

  // 按钮渐变（保持 const 向后兼容）
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1a2235), Color(0xFF0d1120)],
  );

  static const LinearGradient buttonGradientChecked = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0d2818), Color(0xFF061410)],
  );

  // 7级颜色
  static const List<Color> levelColors = AppThemeColors.levelColors;
  static const Color notClockedColor = AppThemeColors.notClockedColor;

  /// 获取对应级别的颜色
  static Color getLevelColor(int level) => AppThemeColors.getLevelColor(level);

  /// 根据主题模式获取 ThemeData
  static ThemeData getThemeData(Brightness brightness, AppThemeColors colors) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      primaryColor: levelColors[3],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: levelColors[3],
        onPrimary: colors.textPrimary,
        surface: colors.background,
        onSurface: colors.textPrimary,
        secondary: levelColors[2],
        onSecondary: colors.textPrimary,
        error: levelColors[6],
        onError: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: colors.textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.backgroundSecondary,
        selectedItemColor: colors.textPrimary,
        unselectedItemColor: colors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: colors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: colors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: colors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: colors.textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: colors.textTertiary, fontSize: 12),
      ),
    );
  }

  /// 深色主题数据
  static ThemeData get darkTheme =>
      getThemeData(Brightness.dark, const DarkThemeColors());

  /// 亮色主题数据
  static ThemeData get lightTheme =>
      getThemeData(Brightness.light, const LightThemeColors());
}
