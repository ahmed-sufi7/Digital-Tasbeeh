import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_tasbeeh/widgets/action_bar.dart';
import 'package:digital_tasbeeh/providers/counter_provider.dart';
import 'package:digital_tasbeeh/providers/settings_provider.dart';

void main() {
  group('ActionBar Widget Tests', () {
    late CounterProvider counterProvider;
    late SettingsProvider settingsProvider;

    setUp(() {
      counterProvider = CounterProvider();
      settingsProvider = SettingsProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<CounterProvider>.value(value: counterProvider),
          ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ],
        child: const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Stack(
              children: [
                ActionBar(),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('ActionBar renders with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Verify ActionBar container exists
      expect(find.byType(ActionBar), findsOneWidget);
      
      // Verify all five action buttons are present
      expect(find.byIcon(CupertinoIcons.volume_up), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.phone_circle), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.minus), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.refresh_circled), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.star), findsOneWidget);
    });

    testWidgets('Sound toggle button changes state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Initial state should be enabled (true)
      expect(settingsProvider.soundEnabled, true);
      
      // Tap the sound toggle button
      await tester.tap(find.byIcon(CupertinoIcons.volume_up));
      await tester.pumpAndSettle(); // Wait for async operations
      
      // State should be toggled (false)
      expect(settingsProvider.soundEnabled, false);
    });

    testWidgets('Vibration toggle button changes state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Initial state should be enabled (true)
      expect(settingsProvider.vibrationEnabled, true);
      
      // Tap the vibration toggle button
      await tester.tap(find.byIcon(CupertinoIcons.phone_circle));
      await tester.pumpAndSettle(); // Wait for async operations
      
      // State should be toggled (false)
      expect(settingsProvider.vibrationEnabled, false);
    });
  });
}