import 'package:flutter/foundation.dart';
import '../services/count_history_repository.dart';
import '../services/chart_data_service.dart';

enum TimePeriod { weekly, monthly, yearly }

class StatsData {
  final int totalCount;
  final int totalSessions;
  final double averageCount;
  final Map<DateTime, int> dailyData;
  final Map<String, int> tasbeehDistribution;
  final Map<String, double> tasbeehPercentages;

  const StatsData({
    required this.totalCount,
    required this.totalSessions,
    required this.averageCount,
    required this.dailyData,
    required this.tasbeehDistribution,
    required this.tasbeehPercentages,
  });

  static const empty = StatsData(
    totalCount: 0,
    totalSessions: 0,
    averageCount: 0.0,
    dailyData: {},
    tasbeehDistribution: {},
    tasbeehPercentages: {},
  );
}

class StatsProvider extends ChangeNotifier {
  final CountHistoryRepository _countHistoryRepository =
      CountHistoryRepository();

  // State
  StatsData _currentStats = StatsData.empty;
  TimePeriod _selectedTimePeriod = TimePeriod.weekly;
  bool _isLoading = false;
  bool _isLoadingBarChart = false;
  String? _error;

  // Real-time data
  int _realTimeTotalCount = 0;
  Map<String, int> _realTimeTasbeehCounts = {};

  // Cached data for different time periods to avoid unnecessary reloads
  final Map<TimePeriod, Map<DateTime, int>> _cachedBarChartData = {};

  // Getters
  StatsData get currentStats => _currentStats;
  TimePeriod get selectedTimePeriod => _selectedTimePeriod;
  bool get isLoading => _isLoading;
  bool get isLoadingBarChart => _isLoadingBarChart;
  String? get error => _error;
  int get realTimeTotalCount => _realTimeTotalCount;
  Map<String, int> get realTimeTasbeehCounts =>
      Map.unmodifiable(_realTimeTasbeehCounts);

  // Initialize provider
  Future<void> initialize() async {
    await loadStatistics();
    await _loadRealTimeData();
    // Preload data for other time periods in the background
    _preloadTimePeriodsInBackground();
  }

  // Preload data for all time periods in the background for smooth switching
  void _preloadTimePeriodsInBackground() {
    // Use a small delay to not interfere with initial loading
    Future.delayed(const Duration(milliseconds: 500), () async {
      for (final period in TimePeriod.values) {
        if (period != _selectedTimePeriod &&
            !_cachedBarChartData.containsKey(period)) {
          await _loadBarChartDataForPeriod(period);
          // Small delay between each preload to avoid overwhelming the database
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    });
  }

  // Load statistics for current time period
  Future<void> loadStatistics() async {
    _setLoading(true);
    _clearError();

    try {
      final dateRange = _getDateRangeForPeriod(_selectedTimePeriod);

      // Get aggregated data
      final totalCount = await _countHistoryRepository.getTotalAllTimeCount();
      final countStats = await _countHistoryRepository.getCountStatistics(
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      // Get daily data for charts
      final dailyData = await _countHistoryRepository.getDailyAggregatedCounts(
        dateRange.start,
        dateRange.end,
      );

      // Get Tasbeeh distribution
      final tasbeehDistribution = await _countHistoryRepository
          .getCountDistributionByTasbeeh();

      // Calculate percentages
      final tasbeehPercentages = _calculatePercentages(tasbeehDistribution);

      _currentStats = StatsData(
        totalCount: totalCount,
        totalSessions: countStats['totalSessions'] as int,
        averageCount: (countStats['averageCount'] as int).toDouble(),
        dailyData: dailyData,
        tasbeehDistribution: tasbeehDistribution,
        tasbeehPercentages: tasbeehPercentages,
      );

      // Cache the initial bar chart data
      _cachedBarChartData[_selectedTimePeriod] = dailyData;

      _realTimeTotalCount = totalCount;
    } catch (e) {
      _setError('Failed to load statistics: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Change time period without full reload - only update bar chart data
  Future<void> setTimePeriod(TimePeriod period) async {
    if (_selectedTimePeriod != period) {
      _selectedTimePeriod = period;

      // Check if we have cached data for this period
      if (!_cachedBarChartData.containsKey(period)) {
        await _loadBarChartDataForPeriod(period);
      }

      // Only notify listeners to update the bar chart, not the entire screen
      notifyListeners();
    }
  }

  // Load bar chart data for a specific time period without affecting other data
  Future<void> _loadBarChartDataForPeriod(TimePeriod period) async {
    _isLoadingBarChart = true;
    notifyListeners();

    try {
      final dateRange = _getDateRangeForPeriod(period);
      final dailyData = await _countHistoryRepository.getDailyAggregatedCounts(
        dateRange.start,
        dateRange.end,
      );
      _cachedBarChartData[period] = dailyData;
    } catch (e) {
      debugPrint('Failed to load bar chart data for period $period: $e');
    } finally {
      _isLoadingBarChart = false;
    }
  }

  // Update real-time statistics when count changes
  Future<void> updateRealTimeStats(String tasbeehId, int newCount) async {
    try {
      // Update real-time total
      _realTimeTotalCount = await _countHistoryRepository
          .getTotalAllTimeCount();

      // Update real-time Tasbeeh distribution
      _realTimeTasbeehCounts = await _countHistoryRepository
          .getCountDistributionByTasbeeh();

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update real-time stats: $e');
    }
  }

  // Get chart data for bar chart with sophisticated processing
  List<ChartData> getBarChartData() {
    // Use cached data for the selected time period if available
    final barChartData =
        _cachedBarChartData[_selectedTimePeriod] ?? _currentStats.dailyData;
    return ChartDataService.prepareBarChartData(
      barChartData,
      _selectedTimePeriod,
    );
  }

  // Get chart data for pie chart with sophisticated processing
  List<PieChartData> getPieChartData() {
    return ChartDataService.preparePieChartData(
      _currentStats.tasbeehDistribution,
    );
  }

  // Get trend data for progress indicators
  TrendData getTrendData() {
    // For now, return neutral trend - can be enhanced with historical comparison
    return TrendData(
      currentTotal: _realTimeTotalCount,
      previousTotal: 0,
      changePercentage: 0.0,
      trend: TrendDirection.neutral,
    );
  }

  // Validate chart data
  ChartValidationResult validateChartData() {
    return ChartDataService.validateChartData(
      getBarChartData(),
      getPieChartData(),
    );
  }

  // Get statistics summary
  StatsSummary getStatsSummary() {
    return StatsSummary(
      totalCount: _realTimeTotalCount,
      totalSessions: _currentStats.totalSessions,
      averagePerSession: _currentStats.averageCount,
      mostUsedTasbeeh: _getMostUsedTasbeeh(),
      currentStreak: _getCurrentStreak(),
      periodLabel: _getPeriodLabel(),
    );
  }

  // Private helper methods
  DateRange _getDateRangeForPeriod(TimePeriod period) {
    final now = DateTime.now();

    switch (period) {
      case TimePeriod.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekDate = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        final endOfWeek = startOfWeekDate.add(const Duration(days: 7));
        return DateRange(startOfWeekDate, endOfWeek);

      case TimePeriod.monthly:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        return DateRange(startOfMonth, endOfMonth);

      case TimePeriod.yearly:
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year + 1, 1, 1);
        return DateRange(startOfYear, endOfYear);
    }
  }

  Map<String, double> _calculatePercentages(Map<String, int> distribution) {
    final total = distribution.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return {};

    final percentages = <String, double>{};
    for (final entry in distribution.entries) {
      percentages[entry.key] = (entry.value / total) * 100;
    }
    return percentages;
  }

  String _getMostUsedTasbeeh() {
    if (_realTimeTasbeehCounts.isEmpty) return 'None';

    final sortedEntries = _realTimeTasbeehCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.first.key;
  }

  int _getCurrentStreak() {
    // Calculate current daily streak
    // This is a simplified implementation
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);

      if (_currentStats.dailyData.containsKey(dateKey) &&
          _currentStats.dailyData[dateKey]! > 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  String _getPeriodLabel() {
    switch (_selectedTimePeriod) {
      case TimePeriod.weekly:
        return 'This Week';
      case TimePeriod.monthly:
        return 'This Month';
      case TimePeriod.yearly:
        return 'This Year';
    }
  }

  Future<void> _loadRealTimeData() async {
    try {
      _realTimeTotalCount = await _countHistoryRepository
          .getTotalAllTimeCount();
      _realTimeTasbeehCounts = await _countHistoryRepository
          .getCountDistributionByTasbeeh();
    } catch (e) {
      debugPrint('Failed to load real-time data: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _clearError();
  }
}

// Helper classes
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);
}

class ChartData {
  final DateTime date;
  final int count;
  final String label;

  const ChartData({
    required this.date,
    required this.count,
    required this.label,
  });
}

class PieChartData {
  final String name;
  final int count;
  final double percentage;

  const PieChartData({
    required this.name,
    required this.count,
    required this.percentage,
  });
}

class StatsSummary {
  final int totalCount;
  final int totalSessions;
  final double averagePerSession;
  final String mostUsedTasbeeh;
  final int currentStreak;
  final String periodLabel;

  const StatsSummary({
    required this.totalCount,
    required this.totalSessions,
    required this.averagePerSession,
    required this.mostUsedTasbeeh,
    required this.currentStreak,
    required this.periodLabel,
  });
}
