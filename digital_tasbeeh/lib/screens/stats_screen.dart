import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/stats_provider.dart';
import '../widgets/charts/ios_bar_chart.dart';
import '../widgets/charts/ios_pie_chart.dart';
import '../widgets/charts/chart_loading_animation.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize stats when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceColor(isDark),
        middle: Text(
          'Statistics',
          style: AppTextStyles.navigationTitle(isDark),
        ),
      ),
      child: SafeArea(
        child: Consumer<StatsProvider>(
          builder: (context, statsProvider, child) {
            if (statsProvider.isLoading) {
              return const Center(
                child: CupertinoActivityIndicator(radius: 16),
              );
            }

            if (statsProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 48,
                      color: AppColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading statistics',
                      style: AppTextStyles.bodyLarge(isDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statsProvider.error!,
                      style: AppTextStyles.bodyMedium(isDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      onPressed: () => statsProvider.loadStatistics(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final summary = statsProvider.getStatsSummary();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummarySection(context, summary, isDark),

                  const SizedBox(height: 24),

                  // Bar Chart with Time Period Selector
                  _buildBarChartSection(context, statsProvider, isDark),

                  const SizedBox(height: 24),

                  // Pie Chart
                  _buildPieChartSection(context, statsProvider, isDark),

                  const SizedBox(height: 24),

                  // Tasbeeh Distribution
                  _buildTasbeehDistribution(context, statsProvider, isDark),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    StatsSummary summary,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: AppTextStyles.navigationLargeTitle(isDark)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Count',
                _formatNumber(summary.totalCount),
                CupertinoIcons.number,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Sessions',
                _formatNumber(summary.totalSessions),
                CupertinoIcons.clock,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Average',
                _formatNumber(summary.averagePerSession.round()),
                CupertinoIcons.chart_bar,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Streak',
                '${summary.currentStreak} days',
                CupertinoIcons.flame,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor(isDark), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: AppTextStyles.bodyMedium(isDark)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.labelLarge(isDark).copyWith(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartSection(
    BuildContext context,
    StatsProvider statsProvider,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Over Time',
          style: AppTextStyles.navigationLargeTitle(isDark),
        ),
        const SizedBox(height: 16),
        if (statsProvider.isLoading)
          ChartLoadingAnimation(
            isDark: isDark,
            message: 'Preparing chart data...',
            height: 320,
          )
        else if (statsProvider.error != null)
          ChartErrorState(
            isDark: isDark,
            error: statsProvider.error!,
            onRetry: () => statsProvider.loadStatistics(),
            height: 320,
          )
        else
          IOSBarChart(
            data: statsProvider.getBarChartData(),
            timePeriod: statsProvider.selectedTimePeriod,
            isDark: isDark,
            onTimePeriodChanged: (TimePeriod period) {
              statsProvider.setTimePeriod(period);
            },
          ),
      ],
    );
  }

  Widget _buildPieChartSection(
    BuildContext context,
    StatsProvider statsProvider,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasbeeh Distribution',
          style: AppTextStyles.navigationLargeTitle(isDark),
        ),
        const SizedBox(height: 16),
        if (statsProvider.isLoading)
          ChartLoadingAnimation(
            isDark: isDark,
            message: 'Calculating distribution...',
            height: 400,
          )
        else if (statsProvider.error != null)
          ChartErrorState(
            isDark: isDark,
            error: statsProvider.error!,
            onRetry: () => statsProvider.loadStatistics(),
            height: 400,
          )
        else
          IOSPieChart(
            data: statsProvider.getPieChartData(),
            isDark: isDark,
            totalCount: statsProvider.realTimeTotalCount,
          ),
      ],
    );
  }

  Widget _buildTasbeehDistribution(
    BuildContext context,
    StatsProvider statsProvider,
    bool isDark,
  ) {
    final pieData = statsProvider.getPieChartData();

    if (pieData.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasbeeh Breakdown',
            style: AppTextStyles.navigationLargeTitle(isDark),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderColor(isDark),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.chart_pie,
                    size: 32,
                    color: AppColors.textSecondaryColor(isDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No data available',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasbeeh Breakdown',
          style: AppTextStyles.navigationLargeTitle(isDark),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderColor(isDark),
              width: 0.5,
            ),
          ),
          child: Column(
            children: pieData
                .map(
                  (data) => _buildTasbeehDistributionItem(
                    data.name,
                    data.count,
                    data.percentage,
                    isDark,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTasbeehDistributionItem(
    String name,
    int count,
    double percentage,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: AppTextStyles.bodyMedium(isDark))),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: AppTextStyles.bodyMedium(
              isDark,
            ).copyWith(color: AppColors.textSecondaryColor(isDark)),
          ),
          const SizedBox(width: 8),
          Text(
            _formatNumber(count),
            style: AppTextStyles.bodyMedium(
              isDark,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
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
