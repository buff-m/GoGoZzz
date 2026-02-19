/// 应用常量定义
class AppConstants {
  AppConstants._();

  // 数据库表名
  static const String tableSleepRecords = 'sleep_records';
  static const String tableUserSettings = 'user_settings';

  // 打卡时间范围
  static const int clockStartHour = 18; // 18:00
  static const int clockEndHour = 6; // 次日 06:00

  // 默认正常睡觉时间
  static const String defaultNormalTime = '23:00';

  // 正常时间范围
  static const int normalTimeMinHour = 18; // 18:00
  static const int normalTimeMaxHour = 28; // 次日 04:00 (28 = 24 + 4)

  // 颜色级别偏移量（分钟）
  static const List<int> levelOffsets = [
    -40, // 1级 < -40分钟
    -25, // 2级 -40 ~ -25
    -10, // 3级 -25 ~ -10
    10,  // 4级 -10 ~ 10 (正常)
    25,  // 5级 10 ~ 25
    40,  // 6级 25 ~ 40
    // 7级 > 40分钟
  ];

  // 日期格式
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';

  // 周视图显示天数
  static const int weekViewDays = 7;
}
