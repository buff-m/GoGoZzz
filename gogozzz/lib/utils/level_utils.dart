import '../config/theme.dart';
import 'constants.dart';
import 'date_utils.dart';

/// 颜色级别计算工具
class LevelUtils {
  LevelUtils._();

  /// 根据设定时间和实际打卡时间计算颜色级别 (1-7)
  static int calculateLevel(String sleepTime, String normalTime) {
    final offset = AppDateUtils.getTimeOffsetMinutes(sleepTime, normalTime);

    if (offset < AppConstants.levelOffsets[0]) {
      return 1; // 深绿 - 非常早
    } else if (offset < AppConstants.levelOffsets[1]) {
      return 2; // 绿色 - 早
    } else if (offset < AppConstants.levelOffsets[2]) {
      return 3; // 浅绿 - 略早
    } else if (offset < AppConstants.levelOffsets[3]) {
      return 4; // 黄绿色 - 正常
    } else if (offset < AppConstants.levelOffsets[4]) {
      return 5; // 黄色 - 略晚
    } else if (offset < AppConstants.levelOffsets[5]) {
      return 6; // 橙色 - 晚
    } else {
      return 7; // 红色 - 熬夜
    }
  }

  /// 判断当前时间是否在打卡有效时间内 (18:00 - 次日06:00)
  static bool isClockTimeValid() {
    return AppDateUtils.isInClockTimeRange(DateTime.now());
  }

  /// 判断指定时间是否在打卡有效时间内
  static bool isClockTimeValidForTime(DateTime time) {
    return AppDateUtils.isInClockTimeRange(time);
  }

  /// 获取级别对应的颜色
  static int getLevelColorIndex(int level) {
    if (level < 1) return 0;
    if (level > 7) return 6;
    return level - 1;
  }

  /// 获取级别对应的 Color
  static int getLevelColorValue(int level) {
    return AppTheme.levelColors[getLevelColorIndex(level)].value;
  }

  /// 判断是否是熬夜（级别 >= 7）
  static bool isLate(int level) {
    return level >= 7;
  }

  /// 获取级别描述
  static String getLevelDescription(int level, String normalTime) {
    const descriptions = [
      '睡得很早',
      '睡得较早',
      '略早于设定',
      '正常',
      '略晚于设定',
      '较晚',
      '熬夜',
    ];
    if (level < 1 || level > 7) return '未打卡';
    return descriptions[level - 1];
  }

  /// 根据级别获取时间范围描述
  static String getTimeRangeDescription(String normalTime, int level) {
    final normal = AppDateUtils.parseTime(normalTime);
    final hour = normal.hour;
    final minute = normal.minute;

    final ranges = [
      '< ${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute - 40))}',
      '${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute - 40))} ~ ${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute - 25))}',
      '${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute - 25))} ~ ${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute - 10))}',
      '${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute - 10))} ~ ${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute + 10))}',
      '${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute + 10))} ~ ${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute + 25))}',
      '${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute + 25))} ~ ${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute + 40))}',
      '> ${AppDateUtils.formatTime(DateTime(2000, 1, 1, hour, minute + 40))}',
    ];

    if (level < 1 || level > 7) return '--:--';
    return ranges[level - 1];
  }
}
