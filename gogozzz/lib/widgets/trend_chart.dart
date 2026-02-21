import 'package:flutter/material.dart';
import '../config/theme_colors.dart';

/// 趋势对比组件
class TrendChart extends StatelessWidget {
  final int? previousLateDays;
  final int currentLateDays;
  final String currentMonth;
  final String? previousMonth;
  final AppThemeColors colors;

  const TrendChart({
    super.key,
    this.previousLateDays,
    required this.currentLateDays,
    required this.currentMonth,
    this.previousMonth,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final difference = _calculateDifference();

    return Container(
      padding: const EdgeInsets.all(18),
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.textTertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  size: 15,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '熬夜趋势',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _buildMonthBlock(previousMonth ?? '--', previousLateDays, isPrevious: true)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildArrow(difference),
              ),
              Expanded(child: _buildMonthBlock(currentMonth, currentLateDays, isPrevious: false)),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateDifference() {
    if (previousLateDays == null) return 0;
    return previousLateDays! - currentLateDays;
  }

  Widget _buildMonthBlock(String month, int? days, {required bool isPrevious}) {
    final color = isPrevious && days != null
        ? AppThemeColors.levelColors[6].withValues(alpha: 0.7)
        : colors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.backgroundCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            month,
            style: TextStyle(
              fontSize: 11,
              color: colors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            days != null ? '$days' : '--',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            days != null ? '天' : '',
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(int difference) {
    if (previousLateDays == null) {
      return Text(
        'vs',
        style: TextStyle(fontSize: 13, color: colors.textTertiary),
      );
    }

    if (difference == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.remove_rounded, color: colors.textTertiary, size: 20),
          const SizedBox(height: 2),
          Text(
            '持平',
            style: TextStyle(fontSize: 10, color: colors.textTertiary),
          ),
        ],
      );
    }

    final isImprovement = difference > 0;
    final color = isImprovement ? AppThemeColors.levelColors[1] : AppThemeColors.levelColors[6];
    final icon = isImprovement ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final label = isImprovement ? '进步' : '退步';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(
          '${difference.abs()}天',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
