import 'package:flutter/material.dart';
import '../config/theme_colors.dart';

/// 统计卡片组件
class StatCard extends StatelessWidget {
  final String title;
  final int value;
  final String unit;
  final Color? color;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.unit = '天',
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppThemeColors.levelColors[3];

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.08) ?? AppThemeColors.levelColors[3].withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cardColor.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 15, color: cardColor),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: cardColor.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: cardColor,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 13,
                      color: cardColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 熬夜天数卡片
class LateDaysCard extends StatelessWidget {
  final int lateDays;
  final AppThemeColors colors;

  const LateDaysCard({super.key, required this.lateDays, required this.colors});

  @override
  Widget build(BuildContext context) {
    return StatCard(
      title: '熬夜天数',
      value: lateDays,
      color: AppThemeColors.levelColors[6],
      icon: Icons.nightlight_round,
    );
  }
}

/// 打卡天数卡片
class ClockedDaysCard extends StatelessWidget {
  final int clockedDays;
  final AppThemeColors colors;

  const ClockedDaysCard({super.key, required this.clockedDays, required this.colors});

  @override
  Widget build(BuildContext context) {
    return StatCard(
      title: '打卡天数',
      value: clockedDays,
      color: AppThemeColors.levelColors[2],
      icon: Icons.check_circle_outline,
    );
  }
}
