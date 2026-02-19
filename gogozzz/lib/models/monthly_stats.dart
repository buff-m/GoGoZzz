/// 月度统计模型
class MonthlyStats {
  final int year;
  final int month;
  final int totalDays; // 当月总天数
  final int clockedDays; // 打卡天数
  final int lateDays; // 熬夜天数 (level >= 7)
  final String? earliestTime; // 最早睡觉时间
  final String? earliestDate; // 最早睡觉日期
  final String? latestTime; // 最晚睡觉时间
  final String? latestDate; // 最晚睡觉日期

  MonthlyStats({
    required this.year,
    required this.month,
    required this.totalDays,
    required this.clockedDays,
    required this.lateDays,
    this.earliestTime,
    this.earliestDate,
    this.latestTime,
    this.latestDate,
  });

  /// 空统计
  factory MonthlyStats.empty(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0);
    return MonthlyStats(
      year: year,
      month: month,
      totalDays: lastDay.day,
      clockedDays: 0,
      lateDays: 0,
    );
  }

  /// 计算打卡率
  double get clockRate {
    if (totalDays == 0) return 0;
    return clockedDays / totalDays;
  }

  /// 是否有记录
  bool get hasRecords => clockedDays > 0;

  /// 趋势对比结果
  lateDaysComparison(MonthlyStats? previous) {
    if (previous == null || previous.lateDays == 0) {
      return 0;
    }
    return previous.lateDays - lateDays; // 正数表示进步
  }

  @override
  String toString() {
    return 'MonthlyStats($year-$month: $clockedDays/$totalDays days, $lateDays late)';
  }
}
