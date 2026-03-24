/// 时间轴坐标计算工具
class TimeAxisUtils {
  TimeAxisUtils._();

  /// HH:mm 转为自 18:00 起的分钟数
  /// 18:00=0, 23:00=300, 00:00=360, 05:59=719
  static double timeToMinutesFrom18(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour >= 18) {
      return (hour - 18) * 60.0 + minute;
    } else {
      return (hour + 6) * 60.0 + minute;
    }
  }

  /// 计算 Y 轴显示范围
  /// 默认 normalTime 前后各 2.5h，有超出数据则扩展，上下各加 30min padding
  static (double min, double max) calculateVisibleRange(
    List<double> dataPoints,
    String normalTime,
  ) {
    final normalMinutes = timeToMinutesFrom18(normalTime);
    var rangeMin = normalMinutes - 150; // 前 2.5h
    var rangeMax = normalMinutes + 150; // 后 2.5h

    for (final point in dataPoints) {
      if (point < rangeMin) rangeMin = point;
      if (point > rangeMax) rangeMax = point;
    }

    // 上下各加 30min padding
    rangeMin -= 30;
    rangeMax += 30;

    // 限制在有效范围内
    if (rangeMin < 0) rangeMin = 0;
    if (rangeMax > 720) rangeMax = 720;

    return (rangeMin, rangeMax);
  }

  /// 生成每小时刻度标记
  static List<(double minutes, String label)> generateTickMarks(
    double min,
    double max,
  ) {
    final ticks = <(double, String)>[];

    // 从第一个整小时开始
    final startHour = (min / 60).ceil();
    final endHour = (max / 60).floor();

    for (var h = startHour; h <= endHour; h++) {
      final minutes = h * 60.0;
      if (minutes >= min && minutes <= max) {
        ticks.add((minutes, minutesFrom18ToLabel(minutes)));
      }
    }

    return ticks;
  }

  /// 坐标转回 "HH:mm" 格式
  static String minutesFrom18ToLabel(double minutes) {
    final totalMinutes = minutes.round();
    var hour = (totalMinutes ~/ 60) + 18;
    final minute = totalMinutes % 60;

    if (hour >= 24) hour -= 24;

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
