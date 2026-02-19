import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 打卡按钮状态基类
sealed class ClockButtonState {}

/// 可以打卡
class ClockButtonCanClock extends ClockButtonState {}

/// 已打卡
class ClockButtonClocked extends ClockButtonState {
  final String time;
  ClockButtonClocked(this.time);
}

/// 禁用
class ClockButtonDisabled extends ClockButtonState {}

/// 打卡按钮组件
class ClockButton extends StatefulWidget {
  final ClockButtonState state;
  final VoidCallback? onPressed;

  /// 外部调用此方法触发成功动画
  final void Function(void Function() playSuccess)? onAnimationReady;

  const ClockButton({
    super.key,
    required this.state,
    this.onPressed,
    this.onAnimationReady,
  });

  @override
  State<ClockButton> createState() => ClockButtonWidgetState();
}

class ClockButtonWidgetState extends State<ClockButton>
    with TickerProviderStateMixin {
  // 按压缩放
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  // 成功涟漪
  late AnimationController _rippleController;
  late Animation<double> _rippleScale;
  late Animation<double> _rippleOpacity;

  // 成功图标弹入
  late AnimationController _successController;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;

  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleScale = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _successScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _successController, curve: Curves.easeOut));
    _successOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _rippleController.dispose();
    _successController.dispose();
    super.dispose();
  }

  /// 播放打卡成功动画（由外部调用）
  void playSuccessAnimation() {
    setState(() => _showSuccess = true);
    _rippleController.forward(from: 0);
    _successController.forward(from: 0);
    // 成功动画结束后隐藏 overlay
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showSuccess = false);
    });
  }

  bool get _isEnabled => widget.state is ClockButtonCanClock;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isEnabled ? (_) => _pressController.forward() : null,
      onTapUp: _isEnabled
          ? (_) {
              _pressController.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: _isEnabled ? () => _pressController.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 涟漪层
              if (_showSuccess)
                AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, _) => Transform.scale(
                    scale: _rippleScale.value,
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getSuccessColor()
                              .withValues(alpha: _rippleOpacity.value),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              // 主按钮
              _buildButton(),
              // 成功 overlay（短暂显示 ✓）
              if (_showSuccess)
                AnimatedBuilder(
                  animation: _successController,
                  builder: (context, _) => Transform.scale(
                    scale: _successScale.value,
                    child: Opacity(
                      opacity: _successOpacity.value,
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getSuccessColor().withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 64,
                            color: _getSuccessColor(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSuccessColor() => AppTheme.levelColors[2]; // 浅绿

  Widget _buildButton() {
    return Container(
      width: 210,
      height: 210,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getGradient(),
        border: Border.all(color: _getBorderColor(), width: 1.5),
        boxShadow: _getShadows(),
      ),
      child: Center(child: _buildContent()),
    );
  }

  List<BoxShadow> _getShadows() {
    if (widget.state is ClockButtonClocked) {
      final color = _getLevelColor((widget.state as ClockButtonClocked).time);
      return [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 40,
          spreadRadius: 4,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ];
    }
    if (widget.state is ClockButtonCanClock) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF4ade80).withValues(alpha: 0.08),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ];
  }

  LinearGradient _getGradient() {
    if (widget.state is ClockButtonClocked) {
      final color = _getLevelColor((widget.state as ClockButtonClocked).time);
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0.06),
        ],
      );
    }
    if (widget.state is ClockButtonDisabled) {
      return const LinearGradient(
        colors: [Color(0xFF0d1120), Color(0xFF0d1120)],
      );
    }
    return AppTheme.buttonGradient;
  }

  Color _getBorderColor() {
    if (widget.state is ClockButtonClocked) {
      return _getLevelColor((widget.state as ClockButtonClocked).time)
          .withValues(alpha: 0.6);
    }
    if (widget.state is ClockButtonDisabled) return AppTheme.disabledColor;
    return AppTheme.borderColorLight;
  }

  Color _getLevelColor(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final totalMinutes = hour * 60 + minute;
    if (totalMinutes < 22 * 60 + 20) return AppTheme.levelColors[0];
    if (totalMinutes < 22 * 60 + 35) return AppTheme.levelColors[1];
    if (totalMinutes < 22 * 60 + 50) return AppTheme.levelColors[2];
    if (totalMinutes < 23 * 60 + 10) return AppTheme.levelColors[3];
    if (totalMinutes < 23 * 60 + 25) return AppTheme.levelColors[4];
    if (totalMinutes < 23 * 60 + 40) return AppTheme.levelColors[5];
    return AppTheme.levelColors[6];
  }

  Widget _buildContent() {
    if (widget.state is ClockButtonClocked) {
      final clocked = widget.state as ClockButtonClocked;
      final color = _getLevelColor(clocked.time);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.nightlight_round, size: 36, color: color),
          const SizedBox(height: 10),
          Text(
            '已入睡',
            style: TextStyle(
              fontSize: 13,
              color: color.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            clocked.time,
            style: TextStyle(
              fontSize: 32,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ],
      );
    }

    if (widget.state is ClockButtonDisabled) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bedtime_off_outlined, size: 36, color: AppTheme.disabledColor),
          const SizedBox(height: 10),
          Text(
            '仅 18:00 - 06:00',
            style: TextStyle(fontSize: 12, color: AppTheme.textTertiary, letterSpacing: 0.5),
          ),
          const SizedBox(height: 2),
          Text(
            '可打卡',
            style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.nightlight_round,
          size: 40,
          color: AppTheme.textSecondary.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 10),
        Text(
          '点击打卡',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '--:--',
          style: TextStyle(
            fontSize: 32,
            color: AppTheme.textTertiary,
            fontWeight: FontWeight.w300,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}
