import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/sleep_record.dart';
import '../utils/date_utils.dart';
import '../utils/constants.dart';

/// 最近7天视图组件
class WeekView extends StatelessWidget {
  final List<SleepRecord> records;

  const WeekView({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final dates = AppDateUtils.getDateRange(AppConstants.weekViewDays);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          // 星期标题
          Row(
            children: dates.map((date) {
              final dt = AppDateUtils.parseDate(date);
              return Expanded(
                child: Center(
                  child: Text(
                    AppDateUtils.getWeekdayShort(dt.weekday),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // 日期方块
          Row(
            children: dates.map((date) {
              final record = records.where((r) => r.date == date).firstOrNull;
              final isToday = AppDateUtils.isCurrentBelongDate(date);
              return Expanded(
                child: Center(child: _buildDateBlock(date, record, isToday)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBlock(String date, SleepRecord? record, bool isToday) {
    final dt = AppDateUtils.parseDate(date);
    final day = dt.day.toString();

    Color bgColor;
    Color textColor;

    if (record != null) {
      bgColor = AppTheme.getLevelColor(record.level);
      textColor = Colors.black.withValues(alpha: 0.75);
    } else {
      bgColor = AppTheme.backgroundCardLight;
      textColor = AppTheme.textTertiary;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              )
            : null,
        boxShadow: record != null
            ? [
                BoxShadow(
                  color: AppTheme.getLevelColor(record.level)
                      .withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
