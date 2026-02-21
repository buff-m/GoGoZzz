import '../utils/constants.dart';

/// 主题模式枚举
enum AppThemeMode {
  dark, // 暗色
  light, // 亮色
}

/// 用户设置模型
class UserSettings {
  final int id;
  final String normalTime; // 正常睡觉时间 HH:mm
  final AppThemeMode themeMode; // 主题模式
  final String updatedAt; // ISO8601

  UserSettings({
    this.id = 1,
    required this.normalTime,
    this.themeMode = AppThemeMode.dark, // 默认暗色
    required this.updatedAt,
  });

  /// 默认设置
  factory UserSettings.defaultSettings() {
    return UserSettings(
      id: 1,
      normalTime: AppConstants.defaultNormalTime,
      themeMode: AppThemeMode.dark,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// 从 Map 创建实例
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as int,
      normalTime: map['normal_time'] as String,
      themeMode: _parseThemeMode(map['theme_mode'] as String?),
      updatedAt: map['updated_at'] as String,
    );
  }

  /// 解析主题模式
  static AppThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
      default:
        return AppThemeMode.dark;
    }
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'normal_time': normalTime,
      'theme_mode': themeMode.name,
      'updated_at': updatedAt,
    };
  }

  /// 创建副本
  UserSettings copyWith({
    int? id,
    String? normalTime,
    AppThemeMode? themeMode,
    String? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      normalTime: normalTime ?? this.normalTime,
      themeMode: themeMode ?? this.themeMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserSettings(id: $id, normalTime: $normalTime, themeMode: $themeMode)';
  }
}
