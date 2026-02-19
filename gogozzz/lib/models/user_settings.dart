import '../utils/constants.dart';

/// 用户设置模型
class UserSettings {
  final int id;
  final String normalTime; // 正常睡觉时间 HH:mm
  final String updatedAt; // ISO8601

  UserSettings({
    this.id = 1,
    required this.normalTime,
    required this.updatedAt,
  });

  /// 默认设置
  factory UserSettings.defaultSettings() {
    return UserSettings(
      id: 1,
      normalTime: AppConstants.defaultNormalTime,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// 从 Map 创建实例
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as int,
      normalTime: map['normal_time'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'normal_time': normalTime,
      'updated_at': updatedAt,
    };
  }

  /// 创建副本
  UserSettings copyWith({
    int? id,
    String? normalTime,
    String? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      normalTime: normalTime ?? this.normalTime,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserSettings(id: $id, normalTime: $normalTime)';
  }
}
