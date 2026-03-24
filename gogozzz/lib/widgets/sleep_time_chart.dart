import 'package:flutter/material.dart';
import '../config/theme_colors.dart';
import '../models/sleep_record.dart';
import '../utils/time_axis_utils.dart';
import '../utils/level_utils.dart';

/// 睡眠时间棒棒糖图
class SleepTimeChart extends StatefulWidget {
  final List<SleepRecord> records;
  final String normalTime;
  final int totalDays;
  final AppThemeColors colors;
  final void Function(String date, SleepRecord? record)? onDayTap;

  const SleepTimeChart({
    super.key,
    required this.records,
    required this.normalTime,
    this.totalDays = 30,
    required this.colors,
    this.onDayTap,
  });

  @override
  State<SleepTimeChart> createState() => _SleepTimeChartState();
}

class _SleepTimeChartState extends State<SleepTimeChart> {
  late ScrollController _scrollController;
  static const double _chartHeight = 180.0;
  static const double _yAxisWidth = 40.0;
  static const double _xAxisHeight = 24.0;
  static const double _topPadding = 8.0;
  static const int _visibleDays = 30;

  String _titleText = '';
  double _dayWidth = 10.0;
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant SleepTimeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalDays != widget.totalDays) {
      _initialScrollDone = false;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateTitle();
  }

  void _updateTitle() {
    if (!_scrollController.hasClients) return;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: widget.totalDays - 1));

    final scrollOffset = _scrollController.offset;
    final firstVisibleIndex = (scrollOffset / _dayWidth).floor().clamp(0, widget.totalDays - 1);
    final lastVisibleIndex = (firstVisibleIndex + _visibleDays - 1).clamp(0, widget.totalDays - 1);

    final firstDate = startDate.add(Duration(days: firstVisibleIndex));
    final lastDate = startDate.add(Duration(days: lastVisibleIndex));

    final newTitle = '${firstDate.month}月${firstDate.day}日 - ${lastDate.month}月${lastDate.day}日';
    if (newTitle != _titleText) {
      setState(() {
        _titleText = newTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: widget.totalDays - 1));

    // 构建日期到记录的映射
    final recordMap = <String, SleepRecord>{};
    for (final record in widget.records) {
      recordMap[record.date] = record;
    }

    // 生成日期列表
    final dates = List.generate(widget.totalDays, (i) {
      final d = startDate.add(Duration(days: i));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    });

    // 计算 Y 轴范围
    final dataPoints = widget.records
        .map((r) => TimeAxisUtils.timeToMinutesFrom18(r.time))
        .toList();
    final (rangeMin, rangeMax) =
        TimeAxisUtils.calculateVisibleRange(dataPoints, widget.normalTime);
    final ticks = TimeAxisUtils.generateTickMarks(rangeMin, rangeMax);
    final normalMinutes = TimeAxisUtils.timeToMinutesFrom18(widget.normalTime);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 动态标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _titleText,
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 图表区域：固定 Y 轴 + 可滚动图表
          SizedBox(
            height: _chartHeight + _xAxisHeight + _topPadding,
            child: Row(
              children: [
                // 固定 Y 轴标签
                SizedBox(
                  width: _yAxisWidth,
                  child: CustomPaint(
                    size: Size(
                        _yAxisWidth, _chartHeight + _xAxisHeight + _topPadding),
                    painter: _YAxisPainter(
                      ticks: ticks,
                      rangeMin: rangeMin,
                      rangeMax: rangeMax,
                      chartHeight: _chartHeight,
                      topPadding: _topPadding,
                      colors: colors,
                    ),
                  ),
                ),
                // 可滚动图表（用 LayoutBuilder 获取可用宽度）
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      _dayWidth = availableWidth / _visibleDays;
                      final chartWidth = widget.totalDays * _dayWidth;

                      // 初始化标题和滚动位置（仅首次）
                      if (!_initialScrollDone) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients && !_initialScrollDone) {
                            _initialScrollDone = true;
                            _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent);
                            _updateTitle();
                          }
                        });
                      }

                      return GestureDetector(
                        onTapUp: (details) =>
                            _handleTap(details, dates, recordMap),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: CustomPaint(
                            size: Size(
                                chartWidth,
                                _chartHeight + _xAxisHeight + _topPadding),
                            painter: _SleepTimeChartPainter(
                              dates: dates,
                              recordMap: recordMap,
                              normalTime: widget.normalTime,
                              normalMinutes: normalMinutes,
                              rangeMin: rangeMin,
                              rangeMax: rangeMax,
                              ticks: ticks,
                              chartHeight: _chartHeight,
                              dayWidth: _dayWidth,
                              topPadding: _topPadding,
                              xAxisHeight: _xAxisHeight,
                              colors: colors,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 图例
          _buildLegend(colors),
        ],
      ),
    );
  }

  void _handleTap(
    TapUpDetails details,
    List<String> dates,
    Map<String, SleepRecord> recordMap,
  ) {
    final localX = details.localPosition.dx + _scrollController.offset;
    final dayIndex = (localX / _dayWidth).floor();
    if (dayIndex >= 0 && dayIndex < dates.length) {
      final date = dates[dayIndex];
      widget.onDayTap?.call(date, recordMap[date]);
    }
  }

  Widget _buildLegend(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '早睡',
            style: TextStyle(fontSize: 10, color: colors.textTertiary),
          ),
          const SizedBox(width: 6),
          ...AppThemeColors.levelColors.map((color) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              )),
          const SizedBox(width: 6),
          Text(
            '熬夜',
            style: TextStyle(fontSize: 10, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Y 轴标签绘制器（固定不滚动）
class _YAxisPainter extends CustomPainter {
  final List<(double, String)> ticks;
  final double rangeMin;
  final double rangeMax;
  final double chartHeight;
  final double topPadding;
  final AppThemeColors colors;

  _YAxisPainter({
    required this.ticks,
    required this.rangeMin,
    required this.rangeMax,
    required this.chartHeight,
    required this.topPadding,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontSize: 9,
      color: colors.textTertiary,
    );

    for (final (minutes, label) in ticks) {
      final y = topPadding +
          ((minutes - rangeMin) / (rangeMax - rangeMin)) * chartHeight;

      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(size.width - textPainter.width - 4, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_YAxisPainter oldDelegate) =>
      rangeMin != oldDelegate.rangeMin ||
      rangeMax != oldDelegate.rangeMax ||
      ticks.length != oldDelegate.ticks.length;
}

/// 图表主绘制器
class _SleepTimeChartPainter extends CustomPainter {
  final List<String> dates;
  final Map<String, SleepRecord> recordMap;
  final String normalTime;
  final double normalMinutes;
  final double rangeMin;
  final double rangeMax;
  final List<(double, String)> ticks;
  final double chartHeight;
  final double dayWidth;
  final double topPadding;
  final double xAxisHeight;
  final AppThemeColors colors;

  _SleepTimeChartPainter({
    required this.dates,
    required this.recordMap,
    required this.normalTime,
    required this.normalMinutes,
    required this.rangeMin,
    required this.rangeMax,
    required this.ticks,
    required this.chartHeight,
    required this.dayWidth,
    required this.topPadding,
    required this.xAxisHeight,
    required this.colors,
  });

  double _minutesToY(double minutes) {
    return topPadding +
        ((minutes - rangeMin) / (rangeMax - rangeMin)) * chartHeight;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawGridLines(canvas, size);
    _drawNormalTimeLine(canvas, size);
    _drawDataPoints(canvas);
    _drawXAxisLabels(canvas);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = colors.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (final (minutes, _) in ticks) {
      final y = _minutesToY(minutes);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawNormalTimeLine(Canvas canvas, Size size) {
    final normalY = _minutesToY(normalMinutes);
    final dashPaint = Paint()
      ..color = AppThemeColors.levelColors[3].withValues(alpha: 0.6)
      ..strokeWidth = 1.0;

    // 绘制虚线
    const dashWidth = 4.0;
    const dashGap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, normalY),
        Offset((x + dashWidth).clamp(0, size.width), normalY),
        dashPaint,
      );
      x += dashWidth + dashGap;
    }
  }

  void _drawDataPoints(Canvas canvas) {
    final normalY = _minutesToY(normalMinutes);
    // dayWidth 较小时缩小圆点和线宽
    final dotRadius = dayWidth < 20 ? 3.0 : 4.0;
    final lineWidth = dayWidth < 20 ? 1.0 : 1.5;
    final emptyDotRadius = dayWidth < 20 ? 1.5 : 2.0;

    for (var i = 0; i < dates.length; i++) {
      final centerX = i * dayWidth + dayWidth / 2;
      final record = recordMap[dates[i]];

      if (record != null) {
        final minutes = TimeAxisUtils.timeToMinutesFrom18(record.time);
        final y = _minutesToY(minutes);
        final level = LevelUtils.calculateLevel(record.time, normalTime);
        final color = AppThemeColors.getLevelColor(level);

        // 细线连接到 normalTime
        final linePaint = Paint()
          ..color = color.withValues(alpha: 0.4)
          ..strokeWidth = lineWidth;
        canvas.drawLine(Offset(centerX, normalY), Offset(centerX, y), linePaint);

        // 圆点
        final dotPaint = Paint()..color = color;
        canvas.drawCircle(Offset(centerX, y), dotRadius, dotPaint);

        // 白色描边
        final strokePaint = Paint()
          ..color = colors.backgroundCard.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(Offset(centerX, y), dotRadius, strokePaint);
      } else {
        // 无记录 - 灰色小点在 normalTime 位置
        final dotPaint = Paint()
          ..color = colors.disabled.withValues(alpha: 0.4);
        canvas.drawCircle(Offset(centerX, normalY), emptyDotRadius, dotPaint);
      }
    }
  }

  void _drawXAxisLabels(Canvas canvas) {
    final textStyle = TextStyle(
      fontSize: 8,
      color: colors.textTertiary,
    );

    // 根据 dayWidth 动态调整标签间隔
    final labelInterval = dayWidth < 15 ? 5 : 5;

    for (var i = 0; i < dates.length; i++) {
      if (i % labelInterval != 0 && i != dates.length - 1) continue;

      final centerX = i * dayWidth + dayWidth / 2;
      final date = dates[i];
      final day = date.substring(8); // 取 dd 部分
      final month = date.substring(5, 7); // 取 MM 部分

      // 每月1号或第一个标签显示月份
      final label = (day == '01' || i == 0) ? '$month/$day' : day;

      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          centerX - textPainter.width / 2,
          topPadding + chartHeight + 4,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_SleepTimeChartPainter oldDelegate) =>
      dates.length != oldDelegate.dates.length ||
      recordMap.length != oldDelegate.recordMap.length ||
      normalTime != oldDelegate.normalTime ||
      rangeMin != oldDelegate.rangeMin ||
      rangeMax != oldDelegate.rangeMax ||
      dayWidth != oldDelegate.dayWidth;
}
