import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_tasbeeh/widgets/charts/ios_bar_chart.dart';
import 'package:digital_tasbeeh/widgets/charts/ios_pie_chart.dart';
import 'package:digital_tasbeeh/providers/stats_provider.dart';

void main() {
  group('Chart Widgets Tests', () {
    testWidgets('IOSBarChart renders without error', (
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

      expect(find.byType(IOSBarChart), findsOneWidget);
    });

    testWidgets('IOSPieChart renders without error', (
      WidgetTester tester,
    ) async {
      final testData = [
        PieChartData(name: 'Test Tasbeeh', count: 100, percentage: 100.0),
      ];

      await tester.pumpWidget(
        CupertinoApp(
          home: IOSPieChart(data: testData, isDark: false, totalCount: 100),
        ),
      );

      expect(find.byType(IOSPieChart), findsOneWidget);
    });

    testWidgets('Charts show empty state when no data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  IOSBarChart(
                    data: const [],
                    timePeriod: TimePeriod.weekly,
                    isDark: false,
                  ),
                  IOSPieChart(data: const [], isDark: false, totalCount: 0),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('No data available'), findsAtLeastNWidgets(2));
    });
  });
}
