import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/stats_provider.dart' as stats;
import '../../services/chart_accessibility_service.dart';

class IOSPieChart extends StatefulWidget {
  final List<stats.PieChartData> data;
  final bool isDark;
  final int totalCount;

  const IOSPieChart({
    super.key,
    required this.data,
    required this.isDark,
    required this.totalCount,
  });

  @override
  State<IOSPieChart> createState() => _IOSPieChartState();
}

class _IOSPieChartState extends State<IOSPieChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _animation;

  int _touchedIndex = -1;

  // iOS-style color palette for pie chart segments
  static const List<Color> _segmentColors = [
    Color(0xFF007AFF), // Primary blue
    Color(0xFF5AC8FA), // Secondary blue
    Color(0xFF34C759), // Green
    Color(0xFFFF9500), // Orange
    Color(0xFFFF3B30), // Red
    Color(0xFFAF52DE), // Purple
    Color(0xFFFF2D92), // Pink
    Color(0xFF5856D6), // Indigo
    Color(0xFF32D74B), // Light green
    Color(0xFFFFD60A), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
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
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(IOSPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
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
      child: Column(
        children: [_buildChart(), const SizedBox(height: 24), _buildLegend()],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
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
              CupertinoIcons.chart_pie_fill,
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
              'Start counting different Tasbeehs to see distribution',
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

  Widget _buildChart() {
    return SizedBox(
      height: 200,
      child: Semantics(
        label: ChartAccessibilityService.generatePieChartDescription(
          widget.data,
          widget.totalCount,
        ),
        hint: ChartAccessibilityService.generateChartInteractionHint('pie'),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return PieChart(
              PieChartData(
                pieTouchData: _buildPieTouchData(),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: _buildPieSections(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: widget.data.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final data = entry.value;
        final color = _getSegmentColor(index);
        final isSelected = index == _touchedIndex;

        return Semantics(
          label: ChartAccessibilityService.generatePieSegmentDescription(
            data,
            index,
            widget.data.length,
          ),
          button: true,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 16 : 12,
                  height: isSelected ? 16 : 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(isSelected ? 8 : 6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.name,
                    style: AppTextStyles.bodyMedium(widget.isDark).copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${data.percentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.bodyMedium(widget.isDark).copyWith(
                    color: AppColors.textSecondaryColor(widget.isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatNumber(data.count),
                  style: AppTextStyles.bodyMedium(
                    widget.isDark,
                  ).copyWith(fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  PieTouchData _buildPieTouchData() {
    return PieTouchData(
      touchCallback: (FlTouchEvent event, pieTouchResponse) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              pieTouchResponse == null ||
              pieTouchResponse.touchedSection == null) {
            _touchedIndex = -1;
            _scaleController.reverse();
            return;
          }

          final newIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
          if (_touchedIndex != newIndex) {
            _touchedIndex = newIndex;
            _scaleController.forward();
            HapticFeedback.lightImpact();
          }
        });
      },
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedIndex;
      final color = _getSegmentColor(index);

      // Staggered animation for each section
      final animationDelay = index * 0.1;
      final delayedAnimation = Tween<double>(begin: 0.0, end: data.percentage)
          .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                animationDelay.clamp(0.0, 0.7),
                (animationDelay + 0.3).clamp(0.3, 1.0),
                curve: Curves.easeOutCubic,
              ),
            ),
          );

      return PieChartSectionData(
        color: color,
        value: delayedAnimation.value,
        title: isTouched ? '${data.percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 85 : 75,
        titleStyle: AppTextStyles.bodyMedium(widget.isDark).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2),
          ],
        ),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderSide: BorderSide(
          color: AppColors.surfaceColor(widget.isDark),
          width: 2,
        ),
      );
    }).toList();
  }

  Color _getSegmentColor(int index) {
    return _segmentColors[index % _segmentColors.length];
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// Center content widget for the pie chart
class PieChartCenterContent extends StatelessWidget {
  final int totalCount;
  final bool isDark;

  const PieChartCenterContent({
    super.key,
    required this.totalCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Total',
          style: AppTextStyles.bodyMedium(isDark).copyWith(
            color: AppColors.textSecondaryColor(isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatNumber(totalCount),
          style: AppTextStyles.labelLarge(isDark).copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
