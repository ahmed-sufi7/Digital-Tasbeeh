import 'package:flutter_test/flutter_test.dart';
import 'package:digital_tasbeeh/services/chart_data_service.dart';
import 'package:digital_tasbeeh/providers/stats_provider.dart';

void main() {
  group('Debug Aggregation Tests', () {
    test('debug yearly aggregation logic', () {
      // Test data: March 15, 2024
      final rawData = <DateTime, int>{DateTime(2024, 3, 15): 100};

      print('🔍 Debug Yearly Aggregation:');
      print(
        'Raw data: ${rawData.entries.map((e) => '${e.key} -> ${e.value}').join(', ')}',
      );

      // Test what _getAggregatedDate returns for this date
      final testDate = DateTime(2024, 3, 15);
      final aggregatedDate = ChartDataService.aggregateDataByTimePeriod({
        testDate: 100,
      }, TimePeriod.yearly);
      print('Aggregated date result: $aggregatedDate');

      // Test what _generateExpectedDateRange returns
      final result = ChartDataService.prepareBarChartData(
        rawData,
        TimePeriod.yearly,
      );

      print('Chart data results:');
      for (int i = 0; i < result.length; i++) {
        final data = result[i];
        print('  ${i + 1}. ${data.label} (${data.date}) -> ${data.count}');
      }

      // Find March data
      final marchData = result.where((d) => d.label == 'Mar').toList();
      print('March data found: ${marchData.length} entries');
      if (marchData.isNotEmpty) {
        print('March count: ${marchData.first.count}');
        print('March date: ${marchData.first.date}');
      }
    });

    test('debug weekly aggregation logic', () {
      // Test data: Tuesday, January 2, 2024
      final rawData = <DateTime, int>{
        DateTime(2024, 1, 2): 15, // Tuesday
      };

      print('🔍 Debug Weekly Aggregation:');
      print(
        'Raw data: ${rawData.entries.map((e) => '${e.key} -> ${e.value}').join(', ')}',
      );

      final result = ChartDataService.prepareBarChartData(
        rawData,
        TimePeriod.weekly,
      );

      print('Chart data results:');
      for (int i = 0; i < result.length; i++) {
        final data = result[i];
        print('  ${i + 1}. ${data.label} (${data.date}) -> ${data.count}');
      }

      // Find Tuesday data
      final tuesdayData = result.where((d) => d.label == 'Tue').toList();
      print('Tuesday data found: ${tuesdayData.length} entries');
      if (tuesdayData.isNotEmpty) {
        print('Tuesday count: ${tuesdayData.first.count}');
        print('Tuesday date: ${tuesdayData.first.date}');
      }
    });
  });
}
