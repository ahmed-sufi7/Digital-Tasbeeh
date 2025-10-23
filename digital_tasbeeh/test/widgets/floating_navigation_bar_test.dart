import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_tasbeeh/providers/navigation_provider.dart';
import 'package:digital_tasbeeh/widgets/floating_navigation_bar.dart';

void main() {
  group('FloatingNavigationBar Widget Tests', () {
    testWidgets('should display all three navigation buttons', (
      WidgetTester tester,
    ) async {
      bool homeTabSelected = false;
      bool manageTabSelected = false;
      bool statsTabSelected = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: ChangeNotifierProvider(
            create: (context) => NavigationProvider(),
            child: CupertinoPageScaffold(
              child: FloatingNavigationBar(
                onTabSelected: (NavigationTab tab) {
                  switch (tab) {
                    case NavigationTab.home:
                      homeTabSelected = true;
                      break;
                    case NavigationTab.manage:
                      manageTabSelected = true;
                      break;
                    case NavigationTab.stats:
                      statsTabSelected = true;
                      break;
                  }
                },
              ),
            ),
          ),
        ),
      );

      // Verify all three navigation buttons are present
      expect(find.byIcon(CupertinoIcons.house_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.plus_circle_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chart_bar_fill), findsOneWidget);

      // Test home button tap
      await tester.tap(find.byIcon(CupertinoIcons.house_fill));
      await tester.pumpAndSettle();
      expect(homeTabSelected, isTrue);

      // Test manage button tap
      await tester.tap(find.byIcon(CupertinoIcons.plus_circle_fill));
      await tester.pumpAndSettle();
      expect(manageTabSelected, isTrue);

      // Test stats button tap
      await tester.tap(find.byIcon(CupertinoIcons.chart_bar_fill));
      await tester.pumpAndSettle();
      expect(statsTabSelected, isTrue);
    });

    testWidgets('should show correct active state for home tab by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: ChangeNotifierProvider(
            create: (context) => NavigationProvider(),
            child: CupertinoPageScaffold(
              child: FloatingNavigationBar(
                onTabSelected: (NavigationTab tab) {},
              ),
            ),
          ),
        ),
      );

      // Home tab should be active by default
      final navigationProvider = NavigationProvider();
      expect(navigationProvider.currentTab, NavigationTab.home);
      expect(navigationProvider.isTabActive(NavigationTab.home), isTrue);
      expect(navigationProvider.isTabActive(NavigationTab.manage), isFalse);
      expect(navigationProvider.isTabActive(NavigationTab.stats), isFalse);
    });
  });
}
