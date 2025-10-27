import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_tasbeeh/widgets/charts/ios_bar_chart.dart';
import 'package:digital_tasbeeh/providers/stats_provider.dart';

void main() {
  group('Time Period Selector Tests', () {
    testWidgets('should only show Week, Month, Year options', (
      WidgetTester tester,
    ) async {
      final testData = [
        ChartData(date: DateTime.now(), count: 10, label: 'Test'),
      ];

      await tester.pumpWidget(
        CupertinoApp(
          home: IOSBarChart(
            data: testData,
            timePeriod: TimePeriod.weekly,
            isDark: false,
          ),
        ),
      );

      // Verify that only Week, Month, Year options are available
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);

      // Verify that Day option is NOT available
      expect(find.text('Day'), findsNothing);
    });

    test('TimePeriod enum should only contain weekly, monthly, yearly', () {
      final availablePeriods = TimePeriod.values;

      expect(availablePeriods.length, 3);
      expect(availablePeriods.contains(TimePeriod.weekly), true);
      expect(availablePeriods.contains(TimePeriod.monthly), true);
      expect(availablePeriods.contains(TimePeriod.yearly), true);

      print('✅ Available time periods:');
      for (final period in availablePeriods) {
        print('   - ${period.name}');
      }
    });
  });
}
