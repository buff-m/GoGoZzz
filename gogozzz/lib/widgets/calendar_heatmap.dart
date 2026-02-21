import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme_colors.dart';
import '../models/sleep_record.dart';
import '../providers/settings_provider.dart';
import '../utils/date_utils.dart';

/// 日历热力图组件
class CalendarHeatmap extends ConsumerWidget {
  final int year;
  final int month;
  final List<SleepRecord> records;
  final String normalTime;
  final void Function(int year, int month)? onMonthChanged;
  final void Function(String date, SleepRecord? record)? onDayTap;

  const CalendarHeatmap({
    super.key,
    required this.year,
    required this.month,
    required this.records,
    required this.normalTime,
    this.onMonthChanged,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeColorsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        children: [
          _buildMonthSelector(colors),
          const SizedBox(height: 18),
          _buildWeekdayHeader(colors),
          const SizedBox(height: 10),
          _buildCalendarGrid(colors),
          const SizedBox(height: 16),
          _buildLegend(colors),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(AppThemeColors colors) {
    final (prevYear, prevMonth) = AppDateUtils.getPreviousMonth(year, month);
    final (nextYear, nextMonth) = AppDateUtils.getNextMonth(year, month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => onMonthChanged?.call(prevYear, prevMonth),
          colors: colors,
        ),
        Text(
          AppDateUtils.formatMonth(year, month),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        _buildNavButton(
          icon: Icons.chevron_right_rounded,
          onTap: () => onMonthChanged?.call(nextYear, nextMonth),
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap, required AppThemeColors colors}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colors.backgroundCardLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Icon(icon, size: 18, color: colors.textSecondary),
      ),
    );
  }

  Widget _buildWeekdayHeader(AppThemeColors colors) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 11,
                color: colors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(AppThemeColors colors) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    int firstWeekday = firstDay.weekday % 7;

    final recordMap = <String, SleepRecord>{};
    for (final record in records) {
      recordMap[record.date] = record;
    }

    final List<Widget> rows = [];
    List<Widget> currentRow = [];

    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(const Expanded(child: AspectRatio(aspectRatio: 1, child: SizedBox())));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final record = recordMap[dateStr];
      final isToday = AppDateUtils.isToday(dateStr);

      currentRow.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: AspectRatio(
              aspectRatio: 1,
              child: _buildDayCell(day, record, isToday, dateStr, colors),
            ),
          ),
        ),
      );

      if (currentRow.length == 7) {
        rows.add(Row(children: currentRow));
        currentRow = [];
      }
    }

    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(const Expanded(child: AspectRatio(aspectRatio: 1, child: SizedBox())));
      }
      rows.add(Row(children: currentRow));
    }

    return Column(
      children: rows
          .map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: row,
              ))
          .toList(),
    );
  }

  Widget _buildDayCell(int day, SleepRecord? record, bool isToday, String dateStr, AppThemeColors colors) {
    Color bgColor;
    Color textColor;

    if (record != null) {
      bgColor = record.getColor(normalTime);
      textColor = Colors.black.withValues(alpha: 0.7);
    } else {
      bgColor = colors.backgroundCardLight;
      textColor = colors.textTertiary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onDayTap?.call(dateStr, record),
        borderRadius: BorderRadius.circular(7),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(7),
            border: isToday
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
            boxShadow: record != null
                ? [
                    BoxShadow(
                      color: record.getColor(normalTime).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(AppThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '早睡',
          style: TextStyle(fontSize: 10, color: colors.textTertiary),
        ),
        const SizedBox(width: 6),
        ...AppThemeColors.levelColors.map((color) => Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
        const SizedBox(width: 6),
        Text(
          '熬夜',
          style: TextStyle(fontSize: 10, color: colors.textTertiary),
        ),
      ],
    );
  }
}
