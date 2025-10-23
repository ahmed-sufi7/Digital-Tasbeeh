// This is a basic Flutter widget test for Digital Tasbeeh app.

import 'package:flutter_test/flutter_test.dart';

import 'package:digital_tasbeeh/main.dart';

void main() {
  testWidgets('Digital Tasbeeh app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DigitalTasbeehApp());

    // Wait for the app to initialize
    await tester.pumpAndSettle();

    // Verify that our app loads with the counter at 0
    expect(find.text('0'), findsOneWidget);
    
    // Verify that action buttons are present
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });
}
