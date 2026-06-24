import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:byebyebuddy/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home Screen rendering check', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ByeByeBuddyApp());

    // Verify Title and Subtitle exists
    expect(find.text('ByeBye Buddy'), findsOneWidget);
    expect(find.textContaining('Say bye-bye to screens'), findsOneWidget);

    // Verify Start Button is visible
    expect(find.text('Start Screen Time'), findsOneWidget);
  });
}
