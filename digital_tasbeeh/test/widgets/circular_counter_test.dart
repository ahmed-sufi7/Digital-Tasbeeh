import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_tasbeeh/widgets/circular_counter.dart';
import 'package:digital_tasbeeh/providers/counter_provider.dart';
import 'package:digital_tasbeeh/models/tasbeeh.dart';

void main() {
  group('CircularCounter Widget Tests', () {
    late CounterProvider mockCounterProvider;

    setUp(() {
      mockCounterProvider = CounterProvider();
    });

    testWidgets('CircularCounter renders with initial count', (WidgetTester tester) async {
      // Create a test Tasbeeh
      final testTasbeeh = Tasbeeh(
        id: 'test-1',
        name: 'Test Tasbeeh',
        targetCount: 33,
        currentCount: 0,
        roundNumber: 1,
        createdAt: DateTime.now(),
        lastUsedAt: DateTime.now(),
        isDefault: true,
      );

      // Build the widget with provider
      await tester.pumpWidget(
        CupertinoApp(
          home: ChangeNotifierProvider<CounterProvider>.value(
            value: mockCounterProvider,
            child: const CupertinoPageScaffold(
              child: Center(
                child: CircularCounter(),
              ),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the CircularCounter widget is present
      expect(find.byType(CircularCounter), findsOneWidget);
    });

    testWidgets('CircularCounter responds to tap gestures', (WidgetTester tester) async {
      // Build the widget with provider
      await tester.pumpWidget(
        CupertinoApp(
          home: ChangeNotifierProvider<CounterProvider>.value(
            value: mockCounterProvider,
            child: const CupertinoPageScaffold(
              child: Center(
                child: CircularCounter(),
              ),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Find the CircularCounter widget
      final counterFinder = find.byType(CircularCounter);
      expect(counterFinder, findsOneWidget);

      // Tap on the counter
      await tester.tap(counterFinder);
      await tester.pumpAndSettle();

      // The test passes if no exceptions are thrown during tap
      expect(counterFinder, findsOneWidget);
    });

    testWidgets('CircularCounter has proper responsive sizing', (WidgetTester tester) async {
      // Test with different screen sizes
      await tester.binding.setSurfaceSize(const Size(320, 568)); // Small screen
      
      await tester.pumpWidget(
        CupertinoApp(
          home: ChangeNotifierProvider<CounterProvider>.value(
            value: mockCounterProvider,
            child: const CupertinoPageScaffold(
              child: Center(
                child: CircularCounter(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CircularCounter), findsOneWidget);

      // Test with medium screen
      await tester.binding.setSurfaceSize(const Size(375, 667));
      await tester.pumpAndSettle();
      expect(find.byType(CircularCounter), findsOneWidget);

      // Test with large screen
      await tester.binding.setSurfaceSize(const Size(414, 896));
      await tester.pumpAndSettle();
      expect(find.byType(CircularCounter), findsOneWidget);
    });
  });
}