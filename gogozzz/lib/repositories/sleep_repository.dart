import '../models/sleep_record.dart';
import '../models/monthly_stats.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

/// 打卡记录数据访问层
class SleepRepository {
  final DatabaseService _dbService;

  SleepRepository(this._dbService);

  /// 新增打卡记录
  Future<int> insert(SleepRecord record) async {
    final db = await _dbService.database;
    return await db.insert(
      AppConstants.tableSleepRecords,
      record.toMap(),
    );
  }

  /// 按日期查询
  Future<SleepRecord?> getByDate(String date) async {
    final db = await _dbService.database;
    final results = await db.query(
      AppConstants.tableSleepRecords,
      where: 'date = ?',
      whereArgs: [date],
    );

    if (results.isEmpty) return null;
    return SleepRecord.fromMap(results.first);
  }

  /// 按日期范围查询
  Future<List<SleepRecord>> getByDateRange(String startDate, String endDate) async {
    final db = await _dbService.database;
    final results = await db.query(
      AppConstants.tableSleepRecords,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );

    return results.map((map) => SleepRecord.fromMap(map)).toList();
  }

  /// 获取最近N天记录
  Future<List<SleepRecord>> getRecentDays(int days) async {
    final db = await _dbService.database;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));

    final results = await db.query(
      AppConstants.tableSleepRecords,
      where: 'date >= ?',
      whereArgs: [_formatDate(startDate)],
      orderBy: 'date ASC',
    );

    return results.map((map) => SleepRecord.fromMap(map)).toList();
  }

  /// 获取月度统计
  Future<MonthlyStats> getMonthlyStats(int year, int month) async {
    final db = await _dbService.database;

    // 获取当月第一天和最后一天
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final firstDate = _formatDate(firstDay);
    final lastDate = _formatDate(lastDay);

    // 查询当月所有记录
    final results = await db.query(
      AppConstants.tableSleepRecords,
      where: 'date >= ? AND date <= ?',
      whereArgs: [firstDate, lastDate],
      orderBy: 'date ASC',
    );

    final records = results.map((map) => SleepRecord.fromMap(map)).toList();
    final clockedDays = records.length;
    final lateDays = records.where((r) => r.level >= 7).length;

    // 查找最早和最晚记录
    String? earliestTime;
    String? earliestDate;
    String? latestTime;
    String? latestDate;

    if (records.isNotEmpty) {
      // 最早睡觉时间
      final earliest = records.reduce((a, b) =>
          _compareTime(a.time, b.time) < 0 ? a : b);
      earliestTime = earliest.time;
      earliestDate = earliest.date;

      // 最晚睡觉时间
      final latest = records.reduce((a, b) =>
          _compareTime(a.time, b.time) > 0 ? a : b);
      latestTime = latest.time;
      latestDate = latest.date;
    }

    return MonthlyStats(
      year: year,
      month: month,
      totalDays: lastDay.day,
      clockedDays: clockedDays,
      lateDays: lateDays,
      earliestTime: earliestTime,
      earliestDate: earliestDate,
      latestTime: latestTime,
      latestDate: latestDate,
    );
  }

  /// 删除记录（仅用于测试）
  Future<int> delete(String date) async {
    final db = await _dbService.database;
    return await db.delete(
      AppConstants.tableSleepRecords,
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 比较时间字符串（HH:mm），考虑跨天睡眠逻辑
  /// 将时间映射为相对于 18:00 的偏移量
  int _compareTime(String time1, String time2) {
    final offset1 = _getSleepTimeOffset(time1);
    final offset2 = _getSleepTimeOffset(time2);
    return offset1 - offset2;
  }

  /// 获取睡眠时间偏移量（相对于18:00）
  /// 18:00-23:59 → 0-359 分钟
  /// 00:00-05:59 → 360-719 分钟
  int _getSleepTimeOffset(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour >= 18) {
      return (hour - 18) * 60 + minute;
    } else {
      return (hour + 6) * 60 + minute;
    }
  }
}
