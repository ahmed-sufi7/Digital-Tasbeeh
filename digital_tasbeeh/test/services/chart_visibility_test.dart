import 'package:flutter_test/flutter_test.dart';
import 'package:digital_tasbeeh/services/chart_data_service.dart';
import 'package:digital_tasbeeh/providers/stats_provider.dart';

void main() {
  group('Chart Visibility Tests', () {
    test('weekly view should show all 7 days even with sparse data', () {
      // Test data: Only 2 days have data
      final rawData = <DateTime, int>{
        DateTime(2024, 1, 2): 15, // Tuesday
        DateTime(2024, 1, 5): 30, // Friday
      };

      final result = ChartDataService.prepareBarChartData(
        rawData,
        TimePeriod.weekly,
      );

      expect(result.length, 7); // Should have 7 data points (all days of week)
      expect(result.map((d) => d.label).toList(), [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ]);

      // Days without data should have zero counts
      final mondayCount = result.where((d) => d.label == 'Mon').first.count;
      final wednesdayCount = result.where((d) => d.label == 'Wed').first.count;
      expect(mondayCount, 0);
      expect(wednesdayCount, 0);

      print('✅ Weekly view shows all 7 days');
      print('   Labels: ${result.map((d) => d.label).join(', ')}');
      print('   Counts: ${result.map((d) => d.count).join(', ')}');
    });

    test('monthly view should show all weeks even with sparse data', () {
      // Test data: Only one week has data
      final rawData = <DateTime, int>{
        DateTime(2024, 1, 15): 100, // Mid-month
      };

      final result = ChartDataService.prepareBarChartData(
        rawData,
        TimePeriod.monthly,
      );

      expect(result.length, greaterThan(3)); // Should have multiple weeks
      expect(
        result.every((d) => d.label.startsWith('W')),
        true,
      ); // All labels should start with 'W'

      // Most weeks should have zero counts
      final zeroCountWeeks = result.where((d) => d.count == 0).length;
      expect(zeroCountWeeks, greaterThan(0));

      print('✅ Monthly view shows all weeks');
      print('   Data points: ${result.length}');
      print('   Labels: ${result.map((d) => d.label).join(', ')}');
      print('   Counts: ${result.map((d) => d.count).join(', ')}');
    });

    test('yearly view should show all 12 months even with sparse data', () {
      // Test data: Only 2 months have data
      final rawData = <DateTime, int>{
        DateTime(2024, 3, 15): 100, // March
        DateTime(2024, 8, 20): 200, // August
      };

      final result = ChartDataService.prepareBarChartData(
        rawData,
        TimePeriod.yearly,
      );

      expect(result.length, 12); // Should have 12 data points (all months)
      expect(result.map((d) => d.label).toList(), [
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
      ]);

      // Check that months with data have correct counts
      final marchCount = result.where((d) => d.label == 'Mar').first.count;
      final augustCount = result.where((d) => d.label == 'Aug').first.count;
      expect(marchCount, 100);
      expect(augustCount, 200);

      // Check that months without data have zero counts
      final januaryCount = result.where((d) => d.label == 'Jan').first.count;
      final decemberCount = result.where((d) => d.label == 'Dec').first.count;
      expect(januaryCount, 0);
      expect(decemberCount, 0);

      print('✅ Yearly view shows all 12 months');
      print('   Labels: ${result.map((d) => d.label).join(', ')}');
      print('   Counts: ${result.map((d) => d.count).join(', ')}');
    });

    test('empty data should still show all expected bars with zero counts', () {
      final emptyData = <DateTime, int>{};

      // Test weekly
      final weeklyResult = ChartDataService.prepareBarChartData(
        emptyData,
        TimePeriod.weekly,
      );
      expect(weeklyResult.length, 7);
      expect(weeklyResult.every((d) => d.count == 0), true);

      // Test yearly
      final yearlyResult = ChartDataService.prepareBarChartData(
        emptyData,
        TimePeriod.yearly,
      );
      expect(yearlyResult.length, 12);
      expect(yearlyResult.every((d) => d.count == 0), true);

      print('✅ Empty data shows all expected bars with zero counts');
      print('   Weekly bars: ${weeklyResult.length}');
      print('   Yearly bars: ${yearlyResult.length}');
    });
  });
}
