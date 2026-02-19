import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/monthly_stats.dart';
import '../models/sleep_record.dart';
import '../providers/sleep_provider.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/stat_card.dart';
import '../widgets/trend_chart.dart';
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
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.levelColors[3],
                backgroundColor: AppTheme.backgroundCard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: [
                      // 日历热力图
                      statsAsync.when(
                        data: (stats) => _buildCalendarWithData(stats),
                        loading: () => const _LoadingWidget(),
                        error: (e, _) => _ErrorWidget(message: e.toString()),
                      ),
                      const SizedBox(height: 12),
                      // 统计卡片
                      statsAsync.when(
                        data: (stats) => Row(
                          children: [
                            LateDaysCard(lateDays: stats.lateDays),
                            const SizedBox(width: 12),
                            ClockedDaysCard(clockedDays: stats.clockedDays),
                          ],
                        ),
                        loading: () => const _LoadingWidget(),
                        error: (e, _) => _ErrorWidget(message: e.toString()),
                      ),
                      const SizedBox(height: 12),
                      // 极值记录
                      statsAsync.when(
                        data: (stats) => _buildExtremeRecords(stats),
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
                          ),
                          loading: () => const _LoadingWidget(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          const Text(
            '统计',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          _buildHeaderButton(
            icon: Icons.refresh_rounded,
            onTap: _refreshStats,
          ),
          const SizedBox(width: 4),
          _buildHeaderButton(
            icon: Icons.ios_share_rounded,
            onTap: _shareStats,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildCalendarWithData(MonthlyStats stats) {
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
      onMonthChanged: _onMonthChanged,
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

  Widget _buildExtremeRecords(MonthlyStats stats) {
    if (!stats.hasRecords) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: const Center(
          child: Text(
            '本月暂无打卡记录',
            style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '本月极值',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (stats.earliestTime != null)
            _buildExtremeItem(
              icon: Icons.wb_sunny_outlined,
              iconColor: AppTheme.levelColors[1],
              label: '最早入睡',
              time: '${stats.earliestDate} ${stats.earliestTime}',
            ),
          if (stats.earliestTime != null && stats.latestTime != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                color: AppTheme.borderColor,
                height: 1,
              ),
            ),
          if (stats.latestTime != null)
            _buildExtremeItem(
              icon: Icons.nightlight_round,
              iconColor: AppTheme.levelColors[6],
              label: '最晚入睡',
              time: '${stats.latestDate} ${stats.latestTime}',
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
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          time,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _shareStats() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('分享功能开发中...'),
        backgroundColor: AppTheme.backgroundCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.levelColors[3],
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        style: TextStyle(color: AppTheme.levelColors[6], fontSize: 13),
      ),
    );
  }
}
