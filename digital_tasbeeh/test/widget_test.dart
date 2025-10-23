// This is a basic Flutter widget test for Digital Tasbeeh app.

import 'package:flutter_test/flutter_test.dart';

import 'package:digital_tasbeeh/main.dart';

void main() {
  testWidgets('Digital Tasbeeh app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DigitalTasbeehApp());

    // Verify that our app loads with the home screen.
    expect(find.text('Digital Tasbeeh'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Coming Soon...'), findsOneWidget);
  });
}
