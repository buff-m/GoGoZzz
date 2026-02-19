import 'package:intl/intl.dart';

/// 日期工具类
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _monthFormat = DateFormat('yyyy年M月');
  static final DateFormat _fullDateFormat = DateFormat('M月d日 HH:mm');

  /// 获取今日日期字符串 (yyyy-MM-dd)
  static String getTodayString() {
    return _dateFormat.format(DateTime.now());
  }

  /// 格式化日期
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// 格式化时间
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  /// 解析日期字符串
  static DateTime parseDate(String dateStr) {
    return _dateFormat.parse(dateStr);
  }

  /// 解析时间字符串
  static DateTime parseTime(String timeStr, {DateTime? baseDate}) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final date = baseDate ?? DateTime.now();
    // 如果小时 >= 24，表示是次日
    if (hour >= 24) {
      return DateTime(date.year, date.month, date.day + 1, hour - 24, minute);
    }
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// 获取日期字符串（指定天数偏移）
  static String getDateStringOffset(int daysOffset) {
    final date = DateTime.now().add(Duration(days: daysOffset));
    return _dateFormat.format(date);
  }

  /// 获取日期范围（最近N天）
  static List<String> getDateRange(int days) {
    final List<String> dates = [];
    for (int i = days - 1; i >= 0; i--) {
      dates.add(getDateStringOffset(-i));
    }
    return dates;
  }

  /// 获取指定月份的日期范围
  static List<String> getMonthDateRange(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;

    return List.generate(
      daysInMonth,
      (index) => _dateFormat.format(firstDay.add(Duration(days: index))),
    );
  }

  /// 格式化月份显示
  static String formatMonth(int year, int month) {
    return _monthFormat.format(DateTime(year, month));
  }

  /// 获取上一个月
  static (int year, int month) getPreviousMonth(int year, int month) {
    if (month == 1) {
      return (year - 1, 12);
    }
    return (year, month - 1);
  }

  /// 获取下一个月
  static (int year, int month) getNextMonth(int year, int month) {
    if (month == 12) {
      return (year + 1, 1);
    }
    return (year, month + 1);
  }

  /// 格式化完整日期时间显示
  static String formatFullDateTime(String dateStr, String timeStr) {
    final date = parseDate(dateStr);
    final time = parseTime(timeStr, baseDate: date);
    return _fullDateFormat.format(time);
  }

  /// 获取星期几 (1-7, 周一到周日)
  static int getWeekday(DateTime date) {
    return date.weekday;
  }

  /// 获取星期几的中文缩写
  static String getWeekdayShort(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[weekday - 1];
  }

  /// 获取星期几的中文
  static String getWeekdayChinese(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[date.weekday - 1];
  }

  /// 判断是否是今天
  static bool isToday(String dateStr) {
    return dateStr == getTodayString();
  }

  /// 判断是否超过打卡时间范围（18:00-次日06:00）
  static bool isInClockTimeRange(DateTime time) {
    final hour = time.hour;
    // 18:00 - 23:59 或 00:00 - 06:00
    return hour >= 18 || hour < 6;
  }

  /// 计算两个时间之间的偏移（分钟）
  static int getTimeOffsetMinutes(String actualTime, String normalTime) {
    final actual = parseTime(actualTime);
    final normal = parseTime(normalTime);

    // 统一到同一天计算偏移
    final normalizedActual = DateTime(2000, 1, 1, actual.hour, actual.minute);
    final normalizedNormal = DateTime(2000, 1, 1, normal.hour, normal.minute);

    // 如果实际时间小于正常时间，可能跨天了
    int offset = normalizedActual.difference(normalizedNormal).inMinutes;
    if (offset < -720) {
      // 跨了一天（比如实际23:00，正常04:00）
      offset += 24 * 60;
    } else if (offset > 720) {
      // 反向跨天
      offset -= 24 * 60;
    }

    return offset;
  }
}
