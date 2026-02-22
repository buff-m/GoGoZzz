import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme_colors.dart';
import '../providers/sleep_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/clock_button.dart';
import '../widgets/week_view.dart';
import '../widgets/sleep_record_bottom_sheet.dart';
import '../utils/level_utils.dart';

/// 首页
class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSettingsTap;

  const HomeScreen({super.key, this.onSettingsTap});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _clockButtonKey = GlobalKey<ClockButtonWidgetState>();

  @override
  Widget build(BuildContext context) {
    final sleepState = ref.watch(sleepProvider);
    final colors = ref.watch(themeColorsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colors),
            const Spacer(flex: 2),
            _buildClockButton(sleepState, colors),
            const Spacer(flex: 3),
            _buildWeekSection(sleepState, colors),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        children: [
          // Logo 区域
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.backgroundCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border, width: 0.5),
                ),
                child: const Center(
                  child: Text(
                    'Z',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4ade80),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'GoGoZzz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onSettingsTap,
            icon: Icon(
              Icons.tune_rounded,
              size: 22,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockButton(SleepState sleepState, AppThemeColors colors) {
    final normalTime = ref.watch(normalTimeProvider);
    final now = DateTime.now();
    final isValidTime = LevelUtils.isClockTimeValidForTime(now);

    ClockButtonState buttonState;
    if (sleepState.todayRecord != null) {
      buttonState = ClockButtonClocked(sleepState.todayRecord!.time, normalTime);
    } else if (!isValidTime) {
      buttonState = ClockButtonDisabled();
    } else {
      buttonState = ClockButtonCanClock();
    }

    return Column(
      children: [
        ClockButton(
          key: _clockButtonKey,
          state: buttonState,
          onPressed: sleepState.isClocking
              ? null
              : () => _handleClockIn(sleepState),
        ),
        const SizedBox(height: 20),
        if (sleepState.isClocking)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppThemeColors.levelColors[3],
              strokeWidth: 2,
            ),
          )
        else if (sleepState.error != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppThemeColors.levelColors[6].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppThemeColors.levelColors[6].withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              sleepState.error!,
              style: TextStyle(
                color: AppThemeColors.levelColors[6],
                fontSize: 12,
              ),
            ),
          )
        else
          _buildStatusHint(sleepState, isValidTime, colors),
      ],
    );
  }

  Widget _buildStatusHint(SleepState sleepState, bool isValidTime, AppThemeColors colors) {
    if (sleepState.todayRecord != null) {
      return Text(
        '今日已记录，好好休息 🌙',
        style: TextStyle(
          fontSize: 13,
          color: colors.textTertiary,
          letterSpacing: 0.5,
        ),
      );
    }
    if (!isValidTime) {
      return Text(
        '打卡时间：18:00 - 次日 06:00',
        style: TextStyle(
          fontSize: 13,
          color: colors.textTertiary,
        ),
      );
    }
    return Text(
      '记录今晚的入睡时间',
      style: TextStyle(
        fontSize: 13,
        color: colors.textTertiary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildWeekSection(SleepState sleepState, AppThemeColors colors) {
    final normalTime = ref.watch(normalTimeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              '本周',
              style: TextStyle(
                fontSize: 12,
                color: colors.textTertiary,
                letterSpacing: 1,
              ),
            ),
          ),
          WeekView(
            records: sleepState.recentRecords,
            normalTime: normalTime,
            onDayTap: (date, record) {
              SleepRecordBottomSheet.show(
                context: context,
                date: date,
                record: record,
                normalTime: normalTime,
                onMakeupSuccess: () {
                  ref.read(sleepProvider.notifier).loadRecentRecords(7);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleClockIn(SleepState sleepState) async {
    // 轻触反馈（按下时）
    HapticFeedback.lightImpact();
    await ref.read(sleepProvider.notifier).clockIn();
    // 打卡成功后：振动 + 动画
    final updated = ref.read(sleepProvider);
    if (updated.todayRecord != null && updated.error == null) {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      HapticFeedback.lightImpact();
      _clockButtonKey.currentState?.playSuccessAnimation();
    }
  }
}
