import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme_colors.dart';
import '../models/sleep_record.dart';
import '../providers/settings_provider.dart';
import '../utils/date_utils.dart';
import '../utils/constants.dart';

/// 最近7天视图组件
class WeekView extends ConsumerWidget {
  final List<SleepRecord> records;
  final String normalTime;
  final void Function(String date, SleepRecord? record)? onDayTap;

  const WeekView({
    super.key,
    required this.records,
    required this.normalTime,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeColorsProvider);
    final dates = AppDateUtils.getDateRange(AppConstants.weekViewDays);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 0.5),
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
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textTertiary,
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
                child: Center(child: _buildDateBlock(date, record, isToday, colors)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBlock(String date, SleepRecord? record, bool isToday, AppThemeColors colors) {
    final dt = AppDateUtils.parseDate(date);
    final day = dt.day.toString();

    Color bgColor;
    Color textColor;

    if (record != null) {
      bgColor = record.getColor(normalTime);
      textColor = Colors.black.withValues(alpha: 0.75);
    } else {
      bgColor = colors.backgroundCardLight;
      textColor = colors.textTertiary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onDayTap?.call(date, record),
        borderRadius: BorderRadius.circular(10),
        child: Container(
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
                      color: record.getColor(normalTime).withValues(alpha: 0.3),
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
        ),
      ),
    );
  }
}
