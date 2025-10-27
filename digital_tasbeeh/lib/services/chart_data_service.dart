import 'dart:math' as math;
import '../providers/stats_provider.dart';

class ChartDataService {
  /// Prepares bar chart data with time-based aggregation and smoothing
  static List<ChartData> prepareBarChartData(
    Map<DateTime, int> rawData,
    TimePeriod timePeriod,
  ) {
    if (rawData.isEmpty) return [];

    // First, aggregate data by time period
    final aggregatedData = aggregateDataByTimePeriod(rawData, timePeriod);

    final sortedEntries = aggregatedData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Fill gaps in data for smooth visualization
    final filledData = _fillDataGaps(sortedEntries, timePeriod);

    // Apply data smoothing for better visual representation
    final smoothedData = _applySmoothingFilter(filledData);

    // Convert to ChartData objects with proper labels
    return smoothedData.entries.map((entry) {
      return ChartData(
        date: entry.key,
        count: entry.value,
        label: _formatDateLabel(entry.key, timePeriod),
      );
    }).toList();
  }

  /// Prepares pie chart data with percentage calculations and sorting
  static List<PieChartData> preparePieChartData(
    Map<String, int> rawDistribution,
  ) {
    if (rawDistribution.isEmpty) return [];

    final totalCount = rawDistribution.values.fold(
      0,
      (sum, count) => sum + count,
    );
    if (totalCount == 0) return [];

    // Calculate percentages with proper precision
    final dataList = rawDistribution.entries.map((entry) {
      final percentage = (entry.value / totalCount) * 100;
      return PieChartData(
        name: _formatTasbeehName(entry.key),
        count: entry.value,
        percentage: _roundToDecimalPlaces(percentage, 1),
      );
    }).toList();

    // Sort by count (descending) for better visual hierarchy
    dataList.sort((a, b) => b.count.compareTo(a.count));

    // Ensure percentages add up to 100% (handle rounding errors)
    _adjustPercentagesForRounding(dataList, totalCount);

    return dataList;
  }

  /// Aggregates data by time period with proper date handling
  static Map<DateTime, int> aggregateDataByTimePeriod(
    Map<DateTime, int> rawData,
    TimePeriod timePeriod,
  ) {
    if (rawData.isEmpty) return {};

    final aggregatedData = <DateTime, int>{};

    for (final entry in rawData.entries) {
      final aggregatedDate = _getAggregatedDate(entry.key, timePeriod);
      aggregatedData[aggregatedDate] =
          (aggregatedData[aggregatedDate] ?? 0) + entry.value;
    }

    return aggregatedData;
  }

  /// Calculates trend data for progress indicators
  static TrendData calculateTrendData(
    List<ChartData> currentPeriodData,
    List<ChartData> previousPeriodData,
  ) {
    final currentTotal = currentPeriodData.fold(
      0,
      (sum, data) => sum + data.count,
    );
    final previousTotal = previousPeriodData.fold(
      0,
      (sum, data) => sum + data.count,
    );

    if (previousTotal == 0) {
      return TrendData(
        currentTotal: currentTotal,
        previousTotal: previousTotal,
        changePercentage: currentTotal > 0 ? 100.0 : 0.0,
        trend: currentTotal > 0 ? TrendDirection.up : TrendDirection.neutral,
      );
    }

    final changePercentage =
        ((currentTotal - previousTotal) / previousTotal) * 100;
    final trend = changePercentage > 5
        ? TrendDirection.up
        : changePercentage < -5
        ? TrendDirection.down
        : TrendDirection.neutral;

    return TrendData(
      currentTotal: currentTotal,
      previousTotal: previousTotal,
      changePercentage: _roundToDecimalPlaces(changePercentage, 1),
      trend: trend,
    );
  }

  /// Validates chart data for consistency and completeness
  static ChartValidationResult validateChartData(
    List<ChartData> barData,
    List<PieChartData> pieData,
  ) {
    final issues = <String>[];

    // Check for empty data
    if (barData.isEmpty && pieData.isEmpty) {
      issues.add('No data available for visualization');
    }

    // Validate bar chart data consistency
    if (barData.isNotEmpty) {
      final hasNegativeValues = barData.any((data) => data.count < 0);
      if (hasNegativeValues) {
        issues.add('Bar chart contains negative values');
      }

      final hasDuplicateDates =
          barData.length != barData.map((data) => data.date).toSet().length;
      if (hasDuplicateDates) {
        issues.add('Bar chart contains duplicate dates');
      }
    }

    // Validate pie chart data consistency
    if (pieData.isNotEmpty) {
      final totalPercentage = pieData.fold(
        0.0,
        (sum, data) => sum + data.percentage,
      );
      if ((totalPercentage - 100.0).abs() > 0.1) {
        issues.add('Pie chart percentages do not sum to 100%');
      }

      final hasNegativeValues = pieData.any(
        (data) => data.count < 0 || data.percentage < 0,
      );
      if (hasNegativeValues) {
        issues.add('Pie chart contains negative values');
      }
    }

    return ChartValidationResult(isValid: issues.isEmpty, issues: issues);
  }

  // Private helper methods

  static Map<DateTime, int> _fillDataGaps(
    List<MapEntry<DateTime, int>> sortedData,
    TimePeriod timePeriod,
  ) {
    if (sortedData.isEmpty) return {};

    final filledData = <DateTime, int>{};
    final startDate = sortedData.first.key;
    final endDate = sortedData.last.key;

    // Create a map for quick lookup
    final dataMap = Map.fromEntries(sortedData);

    // Fill gaps based on time period
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      filledData[currentDate] = dataMap[currentDate] ?? 0;
      currentDate = _getNextDate(currentDate, timePeriod);
    }

    return filledData;
  }

  static Map<DateTime, int> _applySmoothingFilter(Map<DateTime, int> data) {
    if (data.length < 3) return data;

    final smoothedData = <DateTime, int>{};
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (int i = 0; i < sortedEntries.length; i++) {
      final current = sortedEntries[i];

      if (i == 0 || i == sortedEntries.length - 1) {
        // Keep first and last values unchanged
        smoothedData[current.key] = current.value;
      } else {
        // Apply simple moving average with weight on current value
        final prev = sortedEntries[i - 1].value;
        final next = sortedEntries[i + 1].value;
        final smoothed = ((prev + (current.value * 2) + next) / 4).round();
        smoothedData[current.key] = smoothed;
      }
    }

    return smoothedData;
  }

  static DateTime _getAggregatedDate(DateTime date, TimePeriod timePeriod) {
    switch (timePeriod) {
      case TimePeriod.weekly:
        // For weekly view, group by individual days (Mon, Tue, Wed, etc.)
        return DateTime(date.year, date.month, date.day);
      case TimePeriod.monthly:
        // For monthly view, group by weeks within the month
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      case TimePeriod.yearly:
        // For yearly view, group by months
        return DateTime(date.year, date.month);
    }
  }

  static DateTime _getNextDate(DateTime date, TimePeriod timePeriod) {
    switch (timePeriod) {
      case TimePeriod.weekly:
        // For weekly view, increment by day
        return date.add(const Duration(days: 1));
      case TimePeriod.monthly:
        // For monthly view, increment by week
        return date.add(const Duration(days: 7));
      case TimePeriod.yearly:
        // For yearly view, increment by month
        return DateTime(date.year, date.month + 1);
    }
  }

  static String _formatDateLabel(DateTime date, TimePeriod timePeriod) {
    switch (timePeriod) {
      case TimePeriod.weekly:
        // Show day names (Mon, Tue, Wed, etc.)
        return _getWeekdayName(date.weekday);
      case TimePeriod.monthly:
        // Show week numbers or week ranges
        final weekOfMonth = ((date.day - 1) ~/ 7) + 1;
        return 'W$weekOfMonth';
      case TimePeriod.yearly:
        // Show month names (Jan, Feb, Mar, etc.)
        return _getMonthName(date.month);
    }
  }

  static String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  static String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String _formatTasbeehName(String name) {
    // Truncate long names for better display
    if (name.length > 20) {
      return '${name.substring(0, 17)}...';
    }
    return name;
  }

  static double _roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = math.pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  static void _adjustPercentagesForRounding(
    List<PieChartData> dataList,
    int totalCount,
  ) {
    if (dataList.isEmpty) return;

    final currentSum = dataList.fold(0.0, (sum, data) => sum + data.percentage);
    final difference = 100.0 - currentSum;

    if (difference.abs() > 0.01) {
      // Adjust the largest segment to ensure total is 100%
      final largestIndex = dataList.indexWhere(
        (data) => data.count == dataList.map((d) => d.count).reduce(math.max),
      );

      if (largestIndex >= 0) {
        final adjustedPercentage =
            dataList[largestIndex].percentage + difference;
        dataList[largestIndex] = PieChartData(
          name: dataList[largestIndex].name,
          count: dataList[largestIndex].count,
          percentage: _roundToDecimalPlaces(adjustedPercentage, 1),
        );
      }
    }
  }
}

// Supporting classes

class TrendData {
  final int currentTotal;
  final int previousTotal;
  final double changePercentage;
  final TrendDirection trend;

  const TrendData({
    required this.currentTotal,
    required this.previousTotal,
    required this.changePercentage,
    required this.trend,
  });
}

enum TrendDirection { up, down, neutral }

class ChartValidationResult {
  final bool isValid;
  final List<String> issues;

  const ChartValidationResult({required this.isValid, required this.issues});
}
