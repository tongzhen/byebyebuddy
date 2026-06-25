import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:byebyebuddy/main.dart';
import 'package:byebyebuddy/widgets/buddy_character.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Full flow: Home -> Countdown -> Time up -> Transition -> Celebration', (WidgetTester tester) async {
    // 1. Build our app
    await tester.pumpWidget(const ByeByeBuddyApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Home Screen
    expect(find.text('ByeBye Buddy'), findsOneWidget);
    expect(find.text('Start Screen Time'), findsOneWidget);

    // 2. Start Screen Time
    await tester.tap(find.text('Start Screen Time'));
    await tester.pump(); 
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Countdown Screen
    expect(find.text('Screen Time'), findsOneWidget);
    expect(find.byType(BuddyCharacter), findsOneWidget);

    // 2.5 Test Pause/Resume Audio
    await tester.tap(find.text('⏸️'));
    await tester.pump();
    expect(find.text('▶️'), findsOneWidget); // Toggle icon check

    await tester.tap(find.text('▶️'));
    await tester.pump();
    expect(find.text('⏸️'), findsOneWidget);

    // 3. Skip to Time Up
    await tester.tap(find.text('⏭️'));
    await tester.pump(); // Transition to Time's up state
    
    // Verify Time Up message
    expect(find.textContaining('Time is up!'), findsOneWidget);
    
    // Wait for the 4-second delay in Time Up sequence
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(); // Transition to Transition screen

    // 4. Verify Transition Screen
    expect(find.text('Time to say bye-bye!'), findsOneWidget);
    expect(find.text('Read a Book'), findsOneWidget);
    expect(find.byType(BuddyCharacter), findsOneWidget);

    // 5. Select an activity
    await tester.tap(find.text('Read a Book'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 6. Verify Celebration Screen
    expect(find.text('Yay! Great Job!'), findsOneWidget);
    expect(find.text('Let\'s Play!'), findsOneWidget);

    // 7. Finish
    await tester.tap(find.text('Let\'s Play!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Back to Home
    expect(find.text('Start Screen Time'), findsOneWidget);
  });

  testWidgets('Settings Screen navigation and Gate', (WidgetTester tester) async {
    await tester.pumpWidget(const ByeByeBuddyApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Open Settings
    await tester.tap(find.text('Parents'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // We should be at the "Parents Only" gate
    expect(find.text('Parents Only'), findsOneWidget);
    
    // Find the math puzzle text (e.g., "5 + 3 = ?")
    final puzzleFinder = find.byWidgetPredicate((widget) => 
      widget is Text && (widget.data?.contains('+') ?? false) && (widget.data?.contains('= ?') ?? false));
    
    expect(puzzleFinder, findsOneWidget);
    final Text puzzleText = tester.widget(puzzleFinder);
    final String puzzle = puzzleText.data!;
    
    // Extract numbers and solve
    final parts = puzzle.split(' ');
    final num1 = int.parse(parts[0]);
    final num2 = int.parse(parts[2]);
    final answer = num1 + num2;

    // Enter answer
    await tester.enterText(find.byType(TextField), answer.toString());
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle(); // This one is fine because gate animations end

    // Now we should be in settings
    expect(find.text('Parent Settings'), findsOneWidget);
    
    // Find back button (AppBar leading)
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Start Screen Time'), findsOneWidget);
  });
}
