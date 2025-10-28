import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/stats_provider.dart';
import '../../services/chart_accessibility_service.dart';

class IOSBarChart extends StatefulWidget {
  final List<ChartData> data;
  final TimePeriod timePeriod;
  final bool isDark;
  final Function(TimePeriod)? onTimePeriodChanged;

  const IOSBarChart({
    super.key,
    required this.data,
    required this.timePeriod,
    required this.isDark,
    this.onTimePeriodChanged,
  });

  @override
  State<IOSBarChart> createState() => _IOSBarChartState();
}

class _IOSBarChartState extends State<IOSBarChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(IOSBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyStateWithSelector();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor(widget.isDark).withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(widget.isDark),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Chart
          Container(
            height: 280,
            padding: const EdgeInsets.all(20),
            child: Semantics(
              label: ChartAccessibilityService.generateBarChartDescription(
                widget.data,
                widget.timePeriod,
              ),
              hint: ChartAccessibilityService.generateChartInteractionHint(
                'bar',
              ),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(),
                      barTouchData: _buildBarTouchData(),
                      titlesData: _buildTitlesData(),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(),
                      gridData: _buildGridData(),
                      backgroundColor: Colors.transparent,
                    ),
                  );
                },
              ),
            ),
          ),
          // Time Period Selector at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildTimePeriodSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    return Semantics(
      label: ChartAccessibilityService.generateTimePeriodSelectorDescription(
        widget.timePeriod,
      ),
      child: CupertinoSlidingSegmentedControl<TimePeriod>(
        groupValue: widget.timePeriod,
        children: {
          TimePeriod.weekly: _buildSegmentChild('Week'),
          TimePeriod.monthly: _buildSegmentChild('Month'),
          TimePeriod.yearly: _buildSegmentChild('Year'),
        },
        onValueChanged: (TimePeriod? value) {
          if (value != null) {
            HapticFeedback.selectionClick();
            widget.onTimePeriodChanged?.call(value);
          }
        },
      ),
    );
  }

  Widget _buildSegmentChild(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: AppTextStyles.fontFamily,
        ),
      ),
    );
  }

  Widget _buildEmptyStateWithSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor(widget.isDark).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Empty state content
          Container(
            height: 280,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.chart_bar_alt_fill,
                    size: 48,
                    color: AppColors.textSecondaryColor(
                      widget.isDark,
                    ).withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: AppTextStyles.bodyLarge(widget.isDark).copyWith(
                      color: AppColors.textSecondaryColor(widget.isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start counting to see your progress',
                    style: AppTextStyles.bodyMedium(widget.isDark).copyWith(
                      color: AppColors.textSecondaryColor(
                        widget.isDark,
                      ).withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Time Period Selector at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildTimePeriodSelector(),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    if (widget.data.isEmpty) return 10;
    final maxCount = widget.data
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b);
    return (maxCount * 1.2).ceilToDouble();
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: AppColors.surfaceColor(widget.isDark),
        tooltipBorder: BorderSide(
          color: AppColors.borderColor(widget.isDark),
          width: 0.5,
        ),
        tooltipRoundedRadius: 12,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final data = widget.data[groupIndex];
          return BarTooltipItem(
            '${data.label}\n${data.count} counts',
            AppTextStyles.bodyMedium(
              widget.isDark,
            ).copyWith(fontWeight: FontWeight.w600),
          );
        },
      ),
      touchCallback: (FlTouchEvent event, barTouchResponse) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              barTouchResponse == null ||
              barTouchResponse.spot == null) {
            _touchedIndex = null;
            return;
          }
          _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          HapticFeedback.lightImpact();
        });
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: _buildBottomTitles,
          reservedSize: 32,
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= widget.data.length) return const SizedBox.shrink();

    final data = widget.data[value.toInt()];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        data.label,
        style: AppTextStyles.bodySmall(widget.isDark).copyWith(
          color: AppColors.textSecondaryColor(widget.isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedIndex;

      // Staggered animation delay
      final animationDelay = index * 0.1;
      final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            animationDelay.clamp(0.0, 0.8),
            (animationDelay + 0.2).clamp(0.2, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.count.toDouble() * delayedAnimation.value,
            gradient: LinearGradient(
              colors: isTouched
                  ? [AppColors.primary, AppColors.secondary.withOpacity(0.8)]
                  : [AppColors.primary.withOpacity(0.8), AppColors.secondary],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: isTouched ? 24 : 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: AppColors.progressTrackColor(
                widget.isDark,
              ).withOpacity(0.1),
            ),
          ),
        ],
      );
    }).toList();
  }

  FlGridData _buildGridData() {
    final maxY = _getMaxY();
    final interval = maxY <= 10
        ? 2.0
        : maxY <= 50
        ? 10.0
        : maxY <= 100
        ? 20.0
        : maxY <= 500
        ? 100.0
        : (maxY / 5).ceilToDouble();

    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppColors.borderColor(widget.isDark).withOpacity(0.2),
          strokeWidth: 0.5,
        );
      },
    );
  }
}
