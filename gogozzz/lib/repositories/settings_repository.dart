import '../models/user_settings.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

/// 用户设置数据访问层
class SettingsRepository {
  final DatabaseService _dbService;

  SettingsRepository(this._dbService);

  /// 获取用户设置
  Future<UserSettings> getSettings() async {
    final db = await _dbService.database;
    final results = await db.query(
      AppConstants.tableUserSettings,
      where: 'id = ?',
      whereArgs: [1],
    );

    if (results.isEmpty) {
      // 如果没有设置，创建默认设置
      final defaultSettings = UserSettings.defaultSettings();
      await db.insert(
        AppConstants.tableUserSettings,
        defaultSettings.toMap(),
      );
      return defaultSettings;
    }

    return UserSettings.fromMap(results.first);
  }

  /// 更新正常睡觉时间
  Future<void> updateNormalTime(String normalTime) async {
    final db = await _dbService.database;
    await db.update(
      AppConstants.tableUserSettings,
      {
        'normal_time': normalTime,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
