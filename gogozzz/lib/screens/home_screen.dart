import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/sleep_provider.dart';
import '../widgets/clock_button.dart';
import '../widgets/week_view.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Spacer(flex: 2),
            _buildClockButton(sleepState),
            const Spacer(flex: 3),
            _buildWeekSection(sleepState),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderColor, width: 0.5),
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
              const Text(
                'GoGoZzz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onSettingsTap,
            icon: const Icon(
              Icons.tune_rounded,
              size: 22,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockButton(SleepState sleepState) {
    final now = DateTime.now();
    final isValidTime = LevelUtils.isClockTimeValidForTime(now);

    ClockButtonState buttonState;
    if (sleepState.todayRecord != null) {
      buttonState = ClockButtonClocked(sleepState.todayRecord!.time);
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
              color: AppTheme.levelColors[3],
              strokeWidth: 2,
            ),
          )
        else if (sleepState.error != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.levelColors[6].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.levelColors[6].withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              sleepState.error!,
              style: TextStyle(
                color: AppTheme.levelColors[6],
                fontSize: 12,
              ),
            ),
          )
        else
          _buildStatusHint(sleepState, isValidTime),
      ],
    );
  }

  Widget _buildStatusHint(SleepState sleepState, bool isValidTime) {
    if (sleepState.todayRecord != null) {
      return Text(
        '今日已记录，好好休息 🌙',
        style: TextStyle(
          fontSize: 13,
          color: AppTheme.textTertiary,
          letterSpacing: 0.5,
        ),
      );
    }
    if (!isValidTime) {
      return Text(
        '打卡时间：18:00 - 次日 06:00',
        style: TextStyle(
          fontSize: 13,
          color: AppTheme.textTertiary,
        ),
      );
    }
    return Text(
      '记录今晚的入睡时间',
      style: TextStyle(
        fontSize: 13,
        color: AppTheme.textTertiary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildWeekSection(SleepState sleepState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              '最近 7 天',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary,
                letterSpacing: 1,
              ),
            ),
          ),
          WeekView(records: sleepState.recentRecords),
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
