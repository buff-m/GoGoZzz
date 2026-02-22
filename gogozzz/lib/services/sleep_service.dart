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

    // 检查是否已打卡（使用归属日期）
    final belongDate = AppDateUtils.getBelongDateString();
    final existing = await _sleepRepository.getByDate(belongDate);
    if (existing != null) {
      throw Exception('该日期已打卡');
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
      date: belongDate,
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

  /// 获取当前归属日期的打卡记录
  Future<SleepRecord?> getTodayRecord() async {
    final belongDate = AppDateUtils.getBelongDateString();
    return await _sleepRepository.getByDate(belongDate);
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

  /// 补卡（为指定日期添加记录）
  Future<SleepRecord> addMakeupRecord({
    required String date,
    required String time,
  }) async {
    // 1. 验证日期：不允许补未来，且只能补近7天
    final targetDate = AppDateUtils.parseDate(date);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (!targetDate.isBefore(todayOnly)) {
      throw Exception('不能为今天或未来的日期补卡');
    }

    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    final sevenDaysAgoOnly = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
    if (targetDate.isBefore(sevenDaysAgoOnly)) {
      throw Exception('只能补近7天内的记录');
    }

    // 2. 验证时间范围 (18:00 - 次日 05:59)
    if (!isValidSleepTime(time)) {
      throw Exception('睡眠时间必须在 18:00 - 次日 05:59 之间');
    }

    // 3. 检查是否已有记录
    final existing = await _sleepRepository.getByDate(date);
    if (existing != null) {
      throw Exception('该日期已有打卡记录');
    }

    // 4. 创建并保存记录
    final settings = await _settingsRepository.getSettings();
    final level = LevelUtils.calculateLevel(time, settings.normalTime);
    final record = SleepRecord(
      date: date,
      time: time,
      level: level,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _sleepRepository.insert(record);
    return record;
  }

  /// 验证睡眠时间是否有效 (18:00 - 次日 05:59)
  bool isValidSleepTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    return hour >= 18 || hour < 6;
  }
}
