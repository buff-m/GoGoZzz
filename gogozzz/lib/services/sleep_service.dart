import '../models/sleep_record.dart';
import '../models/user_settings.dart';
import '../repositories/sleep_repository.dart';
import '../repositories/settings_repository.dart';
import '../utils/date_utils.dart';
import '../utils/level_utils.dart';

/// 打卡业务逻辑服务
class SleepService {
  final SleepRepository _sleepRepository;
  final SettingsRepository _settingsRepository;

  SleepService(this._sleepRepository, this._settingsRepository);

  /// 打卡
  Future<SleepRecord> clockIn() async {
    // 检查打卡时间是否有效
    if (!isClockTimeValid(DateTime.now())) {
      throw Exception('不在打卡时间范围内 (18:00 - 次日06:00)');
    }

    // 检查是否已打卡
    final today = AppDateUtils.getTodayString();
    final existing = await _sleepRepository.getByDate(today);
    if (existing != null) {
      throw Exception('今日已打卡');
    }

    // 获取用户设置
    final settings = await _settingsRepository.getSettings();

    // 记录打卡时间
    final now = DateTime.now();
    final timeStr = AppDateUtils.formatTime(now);

    // 计算颜色级别
    final level = LevelUtils.calculateLevel(timeStr, settings.normalTime);

    // 创建记录
    final record = SleepRecord(
      date: today,
      time: timeStr,
      level: level,
      createdAt: now.toIso8601String(),
    );

    // 保存到数据库
    await _sleepRepository.insert(record);

    return record;
  }

  /// 验证打卡时间是否有效 (18:00 - 次日06:00)
  bool isClockTimeValid(DateTime time) {
    return LevelUtils.isClockTimeValidForTime(time);
  }

  /// 获取今日打卡记录
  Future<SleepRecord?> getTodayRecord() async {
    final today = AppDateUtils.getTodayString();
    return await _sleepRepository.getByDate(today);
  }

  /// 获取最近N天记录
  Future<List<SleepRecord>> getRecentRecords(int days) async {
    return await _sleepRepository.getRecentDays(days);
  }

  /// 获取用户设置
  Future<UserSettings> getSettings() async {
    return await _settingsRepository.getSettings();
  }

  /// 更新正常睡觉时间
  Future<void> updateNormalTime(String normalTime) async {
    await _settingsRepository.updateNormalTime(normalTime);
  }

  /// 获取今日是否可以打卡
  Future<bool> canClockIn() async {
    if (!isClockTimeValid(DateTime.now())) {
      return false;
    }
    final today = await getTodayRecord();
    return today == null;
  }

  /// 获取打卡按钮状态
  Future<bool> canClockInNow() async {
    final now = DateTime.now();
    final isValidTime = isClockTimeValid(now);
    final todayRecord = await getTodayRecord();

    if (todayRecord != null) return false;
    return isValidTime;
  }
}
