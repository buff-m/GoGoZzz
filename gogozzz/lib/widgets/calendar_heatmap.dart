import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/sleep_record.dart';
import '../utils/date_utils.dart';

/// 日历热力图组件
class CalendarHeatmap extends StatelessWidget {
  final int year;
  final int month;
  final List<SleepRecord> records;
  final void Function(int year, int month)? onMonthChanged;

  const CalendarHeatmap({
    super.key,
    required this.year,
    required this.month,
    required this.records,
    this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 18),
          _buildWeekdayHeader(),
          const SizedBox(height: 10),
          _buildCalendarGrid(),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final (prevYear, prevMonth) = AppDateUtils.getPreviousMonth(year, month);
    final (nextYear, nextMonth) = AppDateUtils.getNextMonth(year, month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => onMonthChanged?.call(prevYear, prevMonth),
        ),
        Text(
          AppDateUtils.formatMonth(year, month),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        _buildNavButton(
          icon: Icons.chevron_right_rounded,
          onTap: () => onMonthChanged?.call(nextYear, nextMonth),
        ),
      ],
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.backgroundCardLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
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
              child: _buildDayCell(day, record, isToday),
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

  Widget _buildDayCell(int day, SleepRecord? record, bool isToday) {
    Color bgColor;
    Color textColor;

    if (record != null) {
      bgColor = AppTheme.getLevelColor(record.level);
      textColor = Colors.black.withValues(alpha: 0.7);
    } else {
      bgColor = AppTheme.backgroundCardLight;
      textColor = AppTheme.textTertiary;
    }

    return Container(
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
                  color: AppTheme.getLevelColor(record.level)
                      .withValues(alpha: 0.25),
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
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '早睡',
          style: TextStyle(fontSize: 10, color: AppTheme.textTertiary),
        ),
        const SizedBox(width: 6),
        ...AppTheme.levelColors.map((color) => Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
        const SizedBox(width: 6),
        const Text(
          '熬夜',
          style: TextStyle(fontSize: 10, color: AppTheme.textTertiary),
        ),
      ],
    );
  }
}
