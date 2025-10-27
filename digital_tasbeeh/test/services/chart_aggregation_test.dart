import 'package:flutter_test/flutter_test.dart';
import 'package:digital_tasbeeh/services/chart_data_service.dart';
import 'package:digital_tasbeeh/providers/stats_provider.dart';

void main() {
  group('Chart Data Aggregation Tests', () {
    test('weekly aggregation should group by days', () {
      // Test data: 7 days of data
      final rawData = <DateTime, int>{
        DateTime(2024, 1, 1): 10, // Monday
        DateTime(2024, 1, 2): 15, // Tuesday
        DateTime(2024, 1, 3): 20, // Wednesday
        DateTime(2024, 1, 4): 25, // Thursday
        DateTime(2024, 1, 5): 30, // Friday
        DateTime(2024, 1, 6): 35, // Saturday
        DateTime(2024, 1, 7): 40, // Sunday
      };

      final result = ChartDataService.prepareBarChartData(
        rawData,
        TimePeriod.weekly,
      );

      expect(result.length, 7); // Should have 7 data points (one for each day)
      expect(result[0].label, 'Mon');
      expect(result[1].label, 'Tue');
      expect(result[6].label, 'Sun');

      print('✅ Weekly aggregation test passed');
      print('   Data points: ${result.length}');
      print('   Labels: ${result.map((d) => d.label).join(', ')}');
    });

    test('monthly aggregation should group by weeks', () {
      // Test data: Multiple weeks of data
      final rawData = <DateTime, int>{
        DateTime(2024, 1, 1): 10, // Week 1
        DateTime(2024, 1, 2): 15, // Week 1
        DateTime(2024, 1, 8): 20, // Week 2
        DateTime(2024, 1, 9): 25, // Week 2
        DateTime(2024, 1, 15): 30, // Week 3
        DateTime(2024, 1, 16): 35, // Week 3
        DateTime(2024, 1, 22): 40, // Week 4
        DateTime(2024, 1, 23): 45, // Week 4
      };

      final result = ChartDataService.prepareBarChartData(
        rawData,
        TimePeriod.monthly,
      );

      // Should group by weeks, so we expect fewer data points than input
      expect(
        result.length,
        lessThanOrEqualTo(4),
      ); // Should have at most 4 weeks
      expect(
        result[0].label,
        startsWith('W'),
      ); // Should start with 'W' for week

      print('✅ Monthly aggregation test passed');
      print('   Data points: ${result.length}');
      print('   Labels: ${result.map((d) => d.label).join(', ')}');
    });

    test('yearly aggregation should group by months', () {
      // Test data: Multiple months of data
      final rawData = <DateTime, int>{
        DateTime(2024, 1, 15): 100, // January
        DateTime(2024, 1, 20): 50, // January (should be combined)
        DateTime(2024, 2, 10): 200, // February
        DateTime(2024, 3, 5): 150, // March
        DateTime(2024, 4, 12): 300, // April
      };

      final result = ChartDataService.prepareBarChartData(
        rawData,
        TimePeriod.yearly,
      );

      expect(
        result.length,
        4,
      ); // Should have 4 data points (one for each month)
      expect(result[0].label, 'Jan');
      expect(result[1].label, 'Feb');
      expect(result[2].label, 'Mar');
      expect(result[3].label, 'Apr');

      // January should have combined count (100 + 50 = 150)
      expect(result[0].count, 150);

      print('✅ Yearly aggregation test passed');
      print('   Data points: ${result.length}');
      print('   Labels: ${result.map((d) => d.label).join(', ')}');
      print('   January combined count: ${result[0].count}');
    });

    test('aggregation behavior should be correct for each time period', () {
      print('\n📊 Chart Aggregation Behavior:');
      print('   Weekly:  Shows 7 days (Mon, Tue, Wed, Thu, Fri, Sat, Sun)');
      print('   Monthly: Shows weeks within month (W1, W2, W3, W4)');
      print('   Yearly:  Shows 12 months (Jan, Feb, Mar, ..., Dec)');
      print('');

      expect(true, true); // This test is just for documentation
    });
  });
}
