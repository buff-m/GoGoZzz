import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme_colors.dart';
import '../models/sleep_record.dart';
import '../providers/settings_provider.dart';
import '../utils/date_utils.dart';
import '../utils/level_utils.dart';

/// 睡眠记录详情底部抽屉
class SleepRecordBottomSheet {
  SleepRecordBottomSheet._();

  /// 显示睡眠记录详情
  static Future<void> show({
    required BuildContext context,
    required String date,
    required SleepRecord? record,
    required String normalTime,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SleepRecordBottomSheetContent(
        date: date,
        record: record,
        normalTime: normalTime,
      ),
    );
  }
}

class _SleepRecordBottomSheetContent extends ConsumerWidget {
  final String date;
  final SleepRecord? record;
  final String normalTime;

  const _SleepRecordBottomSheetContent({
    required this.date,
    required this.record,
    required this.normalTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeColorsProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动指示条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textTertiary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: record != null
                ? _buildRecordContent(colors)
                : _buildEmptyContent(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordContent(AppThemeColors colors) {
    final level = record!.getLevel(normalTime);
    final levelColor = record!.getColor(normalTime);
    final description = LevelUtils.getLevelDescription(level, normalTime);
    final offset = AppDateUtils.getTimeOffsetMinutes(record!.time, normalTime);
    final offsetText = _formatOffset(offset);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        _buildDateHeader(colors),
        const SizedBox(height: 20),

        // 打卡信息卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.backgroundCardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border, width: 0.5),
          ),
          child: Row(
            children: [
              // 时间图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: levelColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // 时间和状态
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record!.time,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: levelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 级别指示器
              _buildLevelIndicator(level, colors),
            ],
          ),
        ),

        // 时间偏移信息
        if (offset != 0) ...[
          const SizedBox(height: 12),
          _buildOffsetInfo(offset, offsetText),
        ],
      ],
    );
  }

  Widget _buildEmptyContent(AppThemeColors colors) {
    return Column(
      children: [
        _buildDateHeader(colors),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.backgroundCardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_toggle_off_rounded,
                color: colors.textTertiary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '该日未打卡',
                style: TextStyle(
                  fontSize: 15,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '打卡时间：18:00 - 次日 06:00',
          style: TextStyle(
            fontSize: 12,
            color: colors.textTertiary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(AppThemeColors colors) {
    final dateTime = AppDateUtils.parseDate(date);
    final weekday = AppDateUtils.getWeekdayChinese(dateTime);
    final isToday = AppDateUtils.isToday(date);

    return Row(
      children: [
        Text(
          '${dateTime.month}月${dateTime.day}日',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colors.backgroundCardLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            weekday,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ),
        if (isToday) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppThemeColors.levelColors[3].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '今天',
              style: TextStyle(
                fontSize: 11,
                color: AppThemeColors.levelColors[3],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLevelIndicator(int level, AppThemeColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (index) {
        final isActive = index < level;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppThemeColors.getLevelColor(index + 1)
                : colors.textTertiary.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }

  Widget _buildOffsetInfo(int offset, String offsetText) {
    final isLate = offset > 0;
    final color = isLate ? AppThemeColors.levelColors[5] : AppThemeColors.levelColors[1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLate ? Icons.schedule : Icons.alarm,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            offsetText,
            style: TextStyle(
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatOffset(int offsetMinutes) {
    if (offsetMinutes == 0) {
      return '准时入睡';
    }

    final absMinutes = offsetMinutes.abs();
    final hours = absMinutes ~/ 60;
    final minutes = absMinutes % 60;

    final buffer = StringBuffer();
    if (offsetMinutes > 0) {
      buffer.write('比设定晚 ');
    } else {
      buffer.write('比设定早 ');
    }

    if (hours > 0) {
      buffer.write('$hours 小时 ');
    }
    if (minutes > 0) {
      buffer.write('$minutes 分钟');
    }

    return buffer.toString().trim();
  }
}
