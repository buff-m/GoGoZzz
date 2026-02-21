import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/theme_colors.dart';
import '../models/user_settings.dart';
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
    final colors = ref.watch(themeColorsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, colors),
            Expanded(
              child: settingsAsync.when(
                data: (settings) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionLabel(colors, '外观设置'),
                    const SizedBox(height: 8),
                    _buildThemeSelector(settings, colors),
                    const SizedBox(height: 24),
                    _buildSectionLabel(colors, '睡眠设置'),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      colors: colors,
                      icon: Icons.bedtime_outlined,
                      iconColor: AppThemeColors.levelColors[2],
                      title: '正常睡觉时间',
                      subtitle: '用于计算打卡颜色级别',
                      trailing: _buildTimeSelector(settings.normalTime, colors),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionLabel(colors, '颜色说明'),
                    const SizedBox(height: 8),
                    _buildDescription(colors),
                  ],
                ),
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: AppThemeColors.levelColors[3],
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    '加载失败: $e',
                    style: TextStyle(color: AppThemeColors.levelColors[6]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: colors.textSecondary,
            ),
          ),
          Text(
            '设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(AppThemeColors colors, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: colors.textTertiary,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSettingItem({
    required AppThemeColors colors,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 0.5),
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textTertiary,
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

  /// 主题选择器
  Widget _buildThemeSelector(UserSettings settings, AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppThemeColors.levelColors[3].withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 18,
                  color: AppThemeColors.levelColors[3],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '主题模式',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '选择应用的外观样式',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildThemeOptions(settings, colors),
        ],
      ),
    );
  }

  /// 主题选项
  Widget _buildThemeOptions(UserSettings settings, AppThemeColors colors) {
    final options = [
      (AppThemeMode.dark, '深色', Icons.dark_mode_outlined, '适合夜间使用'),
      (AppThemeMode.light, '浅色', Icons.light_mode_outlined, '适合日间使用'),
    ];

    return Column(
      children: options.map((option) {
        final (mode, label, icon, description) = option;
        final isSelected = settings.themeMode == mode;

        return GestureDetector(
          onTap: () => _updateThemeMode(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppThemeColors.levelColors[3].withValues(alpha: 0.1)
                  : colors.backgroundCardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppThemeColors.levelColors[3].withValues(alpha: 0.5)
                    : colors.border,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppThemeColors.levelColors[3]
                      : colors.textTertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: AppThemeColors.levelColors[3],
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 更新主题模式
  Future<void> _updateThemeMode(AppThemeMode mode) async {
    await ref.read(settingsProvider.notifier).updateThemeMode(mode);
  }

  Widget _buildTimeSelector(String currentTime, AppThemeColors colors) {
    return GestureDetector(
      onTap: () => _showTimePicker(currentTime, colors),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.backgroundCardLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.borderLight, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentTime,
              style: TextStyle(
                fontSize: 16,
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        children: [
          _buildColorLevelItem(colors, 1, '深绿', '< 设定时间 - 40分钟'),
          _buildColorLevelItem(colors, 2, '绿色', '- 40 ~ - 25 分钟'),
          _buildColorLevelItem(colors, 3, '浅绿', '- 25 ~ - 10 分钟'),
          _buildColorLevelItem(colors, 4, '黄绿', '- 10 ~ + 10 分钟（正常）'),
          _buildColorLevelItem(colors, 5, '黄色', '+ 10 ~ + 25 分钟'),
          _buildColorLevelItem(colors, 6, '橙色', '+ 25 ~ + 40 分钟'),
          _buildColorLevelItem(colors, 7, '红色', '> 设定时间 + 40 分钟（熬夜）'),
        ],
      ),
    );
  }

  Widget _buildColorLevelItem(
      AppThemeColors colors, int level, String name, String range) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppThemeColors.getLevelColor(level),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color:
                      AppThemeColors.getLevelColor(level).withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$level级  $name',
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            range,
            style: TextStyle(
              fontSize: 11,
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(String currentTime, AppThemeColors colors) async {
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
              primary: AppThemeColors.levelColors[3],
              surface: colors.backgroundCard,
              onSurface: colors.textPrimary,
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
