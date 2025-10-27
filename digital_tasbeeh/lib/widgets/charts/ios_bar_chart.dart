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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimePeriodSelector(),
        const SizedBox(height: 16),
        _buildChart(),
      ],
    );
  }

  Widget _buildTimePeriodSelector() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(widget.isDark).withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderColor(widget.isDark).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Semantics(
        label: ChartAccessibilityService.generateTimePeriodSelectorDescription(
          widget.timePeriod,
        ),
        child: CupertinoSegmentedControl<TimePeriod>(
          children: {
            TimePeriod.daily: _buildSegmentChild('Day'),
            TimePeriod.weekly: _buildSegmentChild('Week'),
            TimePeriod.monthly: _buildSegmentChild('Month'),
            TimePeriod.yearly: _buildSegmentChild('Year'),
          },
          groupValue: widget.timePeriod,
          onValueChanged: (TimePeriod? value) {
            if (value != null) {
              HapticFeedback.lightImpact();
              widget.onTimePeriodChanged?.call(value);
            }
          },
          selectedColor: AppColors.primary,
          unselectedColor: Colors.transparent,
          borderColor: Colors.transparent,
          pressedColor: AppColors.primary.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildSegmentChild(String text) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium(
          widget.isDark,
        ).copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildChart() {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
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
      child: Semantics(
        label: ChartAccessibilityService.generateBarChartDescription(
          widget.data,
          widget.timePeriod,
        ),
        hint: ChartAccessibilityService.generateChartInteractionHint('bar'),
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
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor(widget.isDark).withOpacity(0.3),
          width: 0.5,
        ),
      ),
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
              style: AppTextStyles.bodyLarge(
                widget.isDark,
              ).copyWith(color: AppColors.textSecondaryColor(widget.isDark)),
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
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: _buildLeftTitles,
          reservedSize: 40,
          interval: _getLeftTitlesInterval(),
        ),
      ),
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

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    return Text(
      _formatCount(value.toInt()),
      style: AppTextStyles.bodySmall(widget.isDark).copyWith(
        color: AppColors.textSecondaryColor(widget.isDark),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  double _getLeftTitlesInterval() {
    final maxY = _getMaxY();
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    return (maxY / 5).ceilToDouble();
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
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _getLeftTitlesInterval(),
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppColors.borderColor(widget.isDark).withOpacity(0.2),
          strokeWidth: 0.5,
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
