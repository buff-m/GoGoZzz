import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme_colors.dart';
import '../models/sleep_record.dart';
import '../providers/settings_provider.dart';
import '../providers/sleep_provider.dart';
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
    VoidCallback? onMakeupSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SleepRecordBottomSheetContent(
        date: date,
        record: record,
        normalTime: normalTime,
        onMakeupSuccess: onMakeupSuccess,
      ),
    );
  }
}

class _SleepRecordBottomSheetContent extends ConsumerStatefulWidget {
  final String date;
  final SleepRecord? record;
  final String normalTime;
  final VoidCallback? onMakeupSuccess;

  const _SleepRecordBottomSheetContent({
    required this.date,
    required this.record,
    required this.normalTime,
    this.onMakeupSuccess,
  });

  @override
  ConsumerState<_SleepRecordBottomSheetContent> createState() => _SleepRecordBottomSheetContentState();
}

class _SleepRecordBottomSheetContentState extends ConsumerState<_SleepRecordBottomSheetContent> {
  @override
  Widget build(BuildContext context) {
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
            child: widget.record != null
                ? _buildRecordContent(colors)
                : _buildEmptyContent(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordContent(AppThemeColors colors) {
    final level = widget.record!.getLevel(widget.normalTime);
    final levelColor = widget.record!.getColor(widget.normalTime);
    final description = LevelUtils.getLevelDescription(level, widget.normalTime);
    final offset = AppDateUtils.getTimeOffsetMinutes(widget.record!.time, widget.normalTime);
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
                      widget.record!.time,
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
    final canMakeup = _canMakeupDate();

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
          '打卡时间：18:00 - 次日 05:59',
          style: TextStyle(
            fontSize: 12,
            color: colors.textTertiary.withValues(alpha: 0.7),
          ),
        ),
        // 补卡按钮
        if (canMakeup) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleMakeup,
              icon: const Icon(Icons.add_alarm, size: 18),
              label: const Text('补卡'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.buttonGradient.colors.first,
                foregroundColor: colors.buttonForeground,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            '仅支持补录近7天内的记录',
            style: TextStyle(
              fontSize: 11,
              color: colors.textTertiary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateHeader(AppThemeColors colors) {
    final dateTime = AppDateUtils.parseDate(widget.date);
    final weekday = AppDateUtils.getWeekdayChinese(dateTime);
    final isToday = AppDateUtils.isToday(widget.date);

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

  /// 检查日期是否可以补卡（只能补近7天内过去的日期）
  bool _canMakeupDate() {
    final targetDate = AppDateUtils.parseDate(widget.date);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // 不能补今天及未来
    if (!targetDate.isBefore(todayOnly)) {
      return false;
    }

    // 只能补近7天
    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    final sevenDaysAgoOnly = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
    if (targetDate.isBefore(sevenDaysAgoOnly)) {
      return false;
    }

    return true;
  }

  /// 处理补卡
  void _handleMakeup() {
    _showSleepTimePicker();
  }

  /// 显示睡眠时间选择器
  void _showSleepTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SleepTimePickerContent(
        date: widget.date,
        normalTime: widget.normalTime,
        onConfirm: _submitMakeup,
      ),
    );
  }

  /// 提交补卡
  Future<void> _submitMakeup(String time) async {
    Navigator.of(context).pop(); // 关闭时间选择器

    final success = await ref.read(sleepProvider.notifier).addMakeupRecord(
      date: widget.date,
      time: time,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(); // 关闭记录详情抽屉
      widget.onMakeupSuccess?.call();

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('补卡成功：${widget.date.substring(5)} $time'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = ref.read(sleepProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? '补卡失败'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// 睡眠时间选择器
class _SleepTimePickerContent extends ConsumerStatefulWidget {
  final String date;
  final String normalTime;
  final Function(String time) onConfirm;

  const _SleepTimePickerContent({
    required this.date,
    required this.normalTime,
    required this.onConfirm,
  });

  @override
  ConsumerState<_SleepTimePickerContent> createState() => _SleepTimePickerContentState();
}

class _SleepTimePickerContentState extends ConsumerState<_SleepTimePickerContent> {
  // 默认选择正常睡觉时间
  late int _selectedHour;
  late int _selectedMinute;

  // 可选的小时列表：18-23 + 00-05
  final List<int> _availableHours = [18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    // 解析 normalTime 作为默认值
    final parts = widget.normalTime.split(':');
    _selectedHour = int.parse(parts[0]);
    _selectedMinute = int.parse(parts[1]);

    // 如果默认小时不在可选范围内，设为 23
    if (!_availableHours.contains(_selectedHour)) {
      _selectedHour = 23;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeColorsProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动条
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textTertiary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '选择睡眠时间',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.date.substring(5),
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // 时间选择器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 小时选择
              _buildPicker(
                values: _availableHours.map((h) => h.toString().padLeft(2, '0')).toList(),
                selectedValue: _selectedHour.toString().padLeft(2, '0'),
                onChanged: (value) => setState(() => _selectedHour = int.parse(value)),
                colors: colors,
              ),
              Text(
                ' : ',
                style: TextStyle(fontSize: 24, color: colors.textPrimary),
              ),
              // 分钟选择
              _buildPicker(
                values: List.generate(60, (i) => i.toString().padLeft(2, '0')),
                selectedValue: _selectedMinute.toString().padLeft(2, '0'),
                onChanged: (value) => setState(() => _selectedMinute = int.parse(value)),
                colors: colors,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 确认按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final time = '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
                widget.onConfirm(time);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.buttonGradient.colors.first,
                foregroundColor: colors.buttonForeground,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '确认补卡',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker({
    required List<String> values,
    required String selectedValue,
    required Function(String) onChanged,
    required AppThemeColors colors,
  }) {
    // 找到初始选中项的索引
    final initialIndex = values.indexOf(selectedValue);

    return Container(
      width: 80,
      height: 150,
      decoration: BoxDecoration(
        color: colors.backgroundCardLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListWheelScrollView.useDelegate(
        itemExtent: 40,
        perspective: 0.005,
        diameterRatio: 1.5,
        controller: FixedExtentScrollController(initialItem: initialIndex >= 0 ? initialIndex : 0),
        onSelectedItemChanged: (index) => onChanged(values[index]),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: values.length,
          builder: (context, index) {
            final isSelected = values[index] == selectedValue;
            return Center(
              child: Text(
                values[index],
                style: TextStyle(
                  fontSize: isSelected ? 24 : 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colors.textPrimary : colors.textTertiary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
