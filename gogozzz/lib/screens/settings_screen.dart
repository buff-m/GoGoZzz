import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/settings_provider.dart';

/// 设置页面
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: settingsAsync.when(
                data: (settings) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionLabel('睡眠设置'),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      icon: Icons.bedtime_outlined,
                      iconColor: AppTheme.levelColors[2],
                      title: '正常睡觉时间',
                      subtitle: '用于计算打卡颜色级别',
                      trailing: _buildTimeSelector(settings.normalTime),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionLabel('颜色说明'),
                    const SizedBox(height: 8),
                    _buildDescription(),
                  ],
                ),
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.levelColors[3],
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    '加载失败: $e',
                    style: TextStyle(color: AppTheme.levelColors[6]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          const Text(
            '设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: AppTheme.textTertiary,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String currentTime) {
    return GestureDetector(
      onTap: () => _showTimePicker(currentTime),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.backgroundCardLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderColorLight, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentTime,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          _buildColorLevelItem(1, '深绿', '< 设定时间 - 40分钟'),
          _buildColorLevelItem(2, '绿色', '- 40 ~ - 25 分钟'),
          _buildColorLevelItem(3, '浅绿', '- 25 ~ - 10 分钟'),
          _buildColorLevelItem(4, '黄绿', '- 10 ~ + 10 分钟（正常）'),
          _buildColorLevelItem(5, '黄色', '+ 10 ~ + 25 分钟'),
          _buildColorLevelItem(6, '橙色', '+ 25 ~ + 40 分钟'),
          _buildColorLevelItem(7, '红色', '> 设定时间 + 40 分钟（熬夜）'),
        ],
      ),
    );
  }

  Widget _buildColorLevelItem(int level, String name, String range) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.getLevelColor(level),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getLevelColor(level).withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$level级  $name',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            range,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(String currentTime) async {
    final parts = currentTime.split(':');
    final initialHour = int.parse(parts[0]);
    final initialMinute = int.parse(parts[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.levelColors[3],
              surface: AppTheme.backgroundCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
      helpText: '选择正常睡觉时间',
      confirmText: '确定',
      cancelText: '取消',
    );

    if (picked != null) {
      final newTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await ref.read(settingsProvider.notifier).updateNormalTime(newTime);
    }
  }
}
