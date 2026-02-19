import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';
import '../repositories/settings_repository.dart';

/// 设置状态管理
class SettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  /// 加载设置
  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 更新正常睡觉时间
  Future<void> updateNormalTime(String normalTime) async {
    try {
      await _repository.updateNormalTime(normalTime);
      await loadSettings();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// 数据库服务 Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// 设置仓库 Provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return SettingsRepository(dbService);
});

/// 设置 Provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<UserSettings>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

/// 正常睡觉时间 Provider（简化访问）
final normalTimeProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.maybeWhen(
    data: (s) => s.normalTime,
    orElse: () => '23:00',
  );
});
