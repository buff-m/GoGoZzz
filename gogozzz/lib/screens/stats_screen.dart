import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme_colors.dart';
import '../models/monthly_stats.dart';
import '../models/sleep_record.dart';
import '../providers/sleep_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/stat_card.dart';
import '../widgets/trend_chart.dart';
import '../widgets/sleep_record_bottom_sheet.dart';
import '../utils/date_utils.dart';

/// 统计页面
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  late int _currentYear;
  late int _currentMonth;
  DateTime _lastRefreshTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
  }

  @override
  Widget build(BuildContext context) {
    final sleepState = ref.watch(sleepProvider);
    final colors = ref.watch(themeColorsProvider);

    if (sleepState.lastUpdated.isAfter(_lastRefreshTime)) {
      _lastRefreshTime = sleepState.lastUpdated;
      ref.invalidate(monthlyStatsProvider((_currentYear, _currentMonth)));
      final previousMonth =
          AppDateUtils.getPreviousMonth(_currentYear, _currentMonth);
      ref.invalidate(monthlyStatsProvider(previousMonth));
    }

    final statsAsync =
        ref.watch(monthlyStatsProvider((_currentYear, _currentMonth)));
    final previousMonth =
        AppDateUtils.getPreviousMonth(_currentYear, _currentMonth);
    final previousStatsAsync = ref.watch(monthlyStatsProvider(previousMonth));

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colors),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppThemeColors.levelColors[3],
                backgroundColor: colors.backgroundCard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: [
                      // 日历热力图
                      statsAsync.when(
                        data: (stats) => _buildCalendarWithData(stats),
                        loading: () => _LoadingWidget(colors: colors),
                        error: (e, _) => _ErrorWidget(message: e.toString(), colors: colors),
                      ),
                      const SizedBox(height: 12),
                      // 统计卡片
                      statsAsync.when(
                        data: (stats) => Row(
                          children: [
                            LateDaysCard(lateDays: stats.lateDays, colors: colors),
                            const SizedBox(width: 12),
                            ClockedDaysCard(clockedDays: stats.clockedDays, colors: colors),
                          ],
                        ),
                        loading: () => _LoadingWidget(colors: colors),
                        error: (e, _) => _ErrorWidget(message: e.toString(), colors: colors),
                      ),
                      const SizedBox(height: 12),
                      // 极值记录
                      statsAsync.when(
                        data: (stats) => _buildExtremeRecords(stats, colors),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                      const SizedBox(height: 12),
                      // 趋势对比
                      statsAsync.when(
                        data: (currentStats) => previousStatsAsync.when(
                          data: (previousStats) => TrendChart(
                            previousLateDays: previousStats.lateDays,
                            currentLateDays: currentStats.lateDays,
                            currentMonth: AppDateUtils.formatMonth(
                                _currentYear, _currentMonth),
                            previousMonth: previousStats.hasRecords
                                ? AppDateUtils.formatMonth(
                                    previousStats.year, previousStats.month)
                                : null,
                            colors: colors,
                          ),
                          loading: () => _LoadingWidget(colors: colors),
                          error: (_, __) => const SizedBox(),
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          Text(
            '统计',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          _buildHeaderButton(
            icon: Icons.refresh_rounded,
            onTap: _refreshStats,
            colors: colors,
          ),
          const SizedBox(width: 4),
          _buildHeaderButton(
            icon: Icons.ios_share_rounded,
            onTap: _shareStats,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap, required AppThemeColors colors}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.backgroundCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Icon(icon, size: 18, color: colors.textSecondary),
      ),
    );
  }

  Widget _buildCalendarWithData(MonthlyStats stats) {
    final normalTime = ref.watch(normalTimeProvider);
    final records = <String, SleepRecord>{};
    final recentRecords = ref.read(sleepProvider).recentRecords;
    for (final record in recentRecords) {
      final recordDate = DateTime.parse(record.date);
      if (recordDate.year == _currentYear &&
          recordDate.month == _currentMonth) {
        records[record.date] = record;
      }
    }

    return CalendarHeatmap(
      year: _currentYear,
      month: _currentMonth,
      records: records.values.toList(),
      normalTime: normalTime,
      onMonthChanged: _onMonthChanged,
      onDayTap: (date, record) {
        SleepRecordBottomSheet.show(
          context: context,
          date: date,
          record: record,
          normalTime: normalTime,
          onMakeupSuccess: () {
            ref.read(sleepProvider.notifier).loadRecentRecords(7);
            _refreshStats();
          },
        );
      },
    );
  }

  Future<void> _refreshStats() async {
    setState(() => _lastRefreshTime = DateTime.now());
    ref.invalidate(monthlyStatsProvider((_currentYear, _currentMonth)));
    final previousMonth =
        AppDateUtils.getPreviousMonth(_currentYear, _currentMonth);
    ref.invalidate(monthlyStatsProvider(previousMonth));
  }

  Future<void> _onRefresh() async => _refreshStats();

  void _onMonthChanged(int year, int month) {
    setState(() {
      _currentYear = year;
      _currentMonth = month;
      _lastRefreshTime = DateTime.now();
    });
  }

  /// 格式化极值显示日期时间
  /// 凌晨 00:00-05:59 的记录，实际打卡日期是归属日期+1天
  String _formatActualDateTime(String date, String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);

    // 凌晨 00:00-05:59 的记录，实际打卡日期是归属日期+1天
    if (hour < 6) {
      final actualDate = DateTime.parse(date).add(const Duration(days: 1));
      return '${AppDateUtils.formatDate(actualDate)} $time';
    }
    return '$date $time';
  }

  Widget _buildExtremeRecords(MonthlyStats stats, AppThemeColors colors) {
    if (!stats.hasRecords) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Center(
          child: Text(
            '本月暂无打卡记录',
            style: TextStyle(color: colors.textTertiary, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
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
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '本月极值',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (stats.earliestTime != null)
            _buildExtremeItem(
              icon: Icons.wb_sunny_outlined,
              iconColor: AppThemeColors.levelColors[1],
              label: '最早入睡',
              time: _formatActualDateTime(stats.earliestDate!, stats.earliestTime!),
              colors: colors,
            ),
          if (stats.earliestTime != null && stats.latestTime != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                color: colors.border,
                height: 1,
              ),
            ),
          if (stats.latestTime != null)
            _buildExtremeItem(
              icon: Icons.nightlight_round,
              iconColor: AppThemeColors.levelColors[6],
              label: '最晚入睡',
              time: _formatActualDateTime(stats.latestDate!, stats.latestTime!),
              colors: colors,
            ),
        ],
      ),
    );
  }

  Widget _buildExtremeItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String time,
    required AppThemeColors colors,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          time,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _shareStats() {
    final colors = ref.read(themeColorsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('分享功能开发中...'),
        backgroundColor: colors.backgroundCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  final AppThemeColors colors;

  const _LoadingWidget({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(
          color: AppThemeColors.levelColors[3],
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final AppThemeColors colors;

  const _ErrorWidget({required this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        style: TextStyle(color: AppThemeColors.levelColors[6], fontSize: 13),
      ),
    );
  }
}
