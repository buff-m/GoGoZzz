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

  /// 比较时间字符串（HH:mm）
  int _compareTime(String time1, String time2) {
    final t1 = time1.split(':');
    final t2 = time2.split(':');
    final h1 = int.parse(t1[0]);
    final m1 = int.parse(t1[1]);
    final h2 = int.parse(t2[0]);
    final m2 = int.parse(t2[1]);

    if (h1 != h2) return h1 - h2;
    return m1 - m2;
  }
}
