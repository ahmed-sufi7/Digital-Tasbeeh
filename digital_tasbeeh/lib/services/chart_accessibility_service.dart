import '../providers/stats_provider.dart';

class ChartAccessibilityService {
  /// Generates accessibility description for bar chart
  static String generateBarChartDescription(
    List<ChartData> data,
    TimePeriod timePeriod,
  ) {
    if (data.isEmpty) {
      return 'Bar chart showing no data available for the selected time period';
    }

    final totalCount = data.fold(0, (sum, item) => sum + item.count);
    final maxCount = data
        .map((item) => item.count)
        .reduce((a, b) => a > b ? a : b);
    final maxItem = data.firstWhere((item) => item.count == maxCount);

    final periodName = _getTimePeriodName(timePeriod);
    final dataPointCount = data.length;

    String description =
        'Bar chart showing $periodName progress with $dataPointCount data points. ';
    description += 'Total count: $totalCount. ';
    description +=
        'Highest activity: ${maxItem.count} counts on ${maxItem.label}. ';

    // Add trend information
    if (data.length >= 2) {
      final firstCount = data.first.count;
      final lastCount = data.last.count;
      if (lastCount > firstCount) {
        description += 'Trend: increasing activity over time.';
      } else if (lastCount < firstCount) {
        description += 'Trend: decreasing activity over time.';
      } else {
        description += 'Trend: stable activity over time.';
      }
    }

    return description;
  }

  /// Generates accessibility description for pie chart
  static String generatePieChartDescription(
    List<PieChartData> data,
    int totalCount,
  ) {
    if (data.isEmpty) {
      return 'Pie chart showing no Tasbeeh distribution data available';
    }

    String description =
        'Pie chart showing distribution of $totalCount total counts across ${data.length} Tasbeehs. ';

    // Add information about top 3 segments
    final topSegments = data.take(3).toList();
    for (int i = 0; i < topSegments.length; i++) {
      final segment = topSegments[i];
      final position = i == 0
          ? 'Largest'
          : i == 1
          ? 'Second largest'
          : 'Third largest';
      description +=
          '$position segment: ${segment.name} with ${segment.count} counts, ${segment.percentage.toStringAsFixed(1)}%. ';
    }

    if (data.length > 3) {
      final remainingCount = data
          .skip(3)
          .fold(0, (sum, item) => sum + item.count);
      final remainingPercentage = data
          .skip(3)
          .fold(0.0, (sum, item) => sum + item.percentage);
      description +=
          'Remaining ${data.length - 3} Tasbeehs account for $remainingCount counts, ${remainingPercentage.toStringAsFixed(1)}%.';
    }

    return description;
  }

  /// Generates accessibility description for individual bar chart data point
  static String generateBarDataPointDescription(
    ChartData data,
    int index,
    int totalDataPoints,
    TimePeriod timePeriod,
  ) {
    final position = index + 1;
    final periodName = _getTimePeriodName(timePeriod);

    return 'Data point $position of $totalDataPoints. ${data.label}: ${data.count} counts. Double tap to hear details.';
  }

  /// Generates accessibility description for individual pie chart segment
  static String generatePieSegmentDescription(
    PieChartData data,
    int index,
    int totalSegments,
  ) {
    final position = index + 1;
    return 'Segment $position of $totalSegments. ${data.name}: ${data.count} counts, ${data.percentage.toStringAsFixed(1)}% of total. Double tap to hear details.';
  }

  /// Generates accessibility hint for chart interactions
  static String generateChartInteractionHint(String chartType) {
    switch (chartType.toLowerCase()) {
      case 'bar':
        return 'Swipe left or right to navigate between data points. Double tap to hear detailed information.';
      case 'pie':
        return 'Swipe left or right to navigate between segments. Double tap to hear detailed information.';
      default:
        return 'Use swipe gestures to navigate chart elements. Double tap for details.';
    }
  }

  /// Generates accessibility description for time period selector
  static String generateTimePeriodSelectorDescription(
    TimePeriod selectedPeriod,
  ) {
    final periodName = _getTimePeriodName(selectedPeriod);
    return 'Time period selector. Currently showing $periodName view. Swipe left or right to change time period.';
  }

  /// Generates accessibility description for chart loading state
  static String generateLoadingDescription(String chartType) {
    return '$chartType chart is loading. Please wait while data is being prepared.';
  }

  /// Generates accessibility description for chart error state
  static String generateErrorDescription(String chartType, String error) {
    return '$chartType chart failed to load. Error: $error. Retry button available.';
  }

  /// Generates accessibility description for empty chart state
  static String generateEmptyStateDescription(String chartType) {
    return '$chartType chart has no data to display. Start counting to see your progress.';
  }

  // Private helper methods

  static String _getTimePeriodName(TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return 'weekly';
      case TimePeriod.monthly:
        return 'monthly';
      case TimePeriod.yearly:
        return 'yearly';
    }
  }
}

/// Extension to add accessibility support to chart data
extension ChartDataAccessibility on ChartData {
  String get accessibilityLabel => '$label: $count counts';

  String get accessibilityHint =>
      'Chart data point showing $count counts for $label';
}

/// Extension to add accessibility support to pie chart data
extension PieChartDataAccessibility on PieChartData {
  String get accessibilityLabel =>
      '$name: $count counts, ${percentage.toStringAsFixed(1)}%';

  String get accessibilityHint =>
      'Pie chart segment for $name representing ${percentage.toStringAsFixed(1)}% of total counts';
}
