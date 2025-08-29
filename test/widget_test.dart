// This is a basic Flutter widget test for Music AI Generator Mobile
// Created by Sergie Code

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_ai_generator_mobile/main.dart';

void main() {
  testWidgets('Music AI Generator app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MusicAIGeneratorApp());

    // Wait for all animations and async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app contains the expected text
    expect(find.text('Music AI Generator'), findsOneWidget);
    expect(find.text('Created by Sergie Code'), findsOneWidget);
    
    // Verify that the main UI elements are present
    expect(find.text('Music Description'), findsOneWidget);
    expect(find.text('🎵 Generate Music'), findsOneWidget);
    
    // Verify server status is shown
    expect(find.textContaining('Server'), findsOneWidget);
    
    // Verify duration controls are present
    expect(find.textContaining('Duration:'), findsOneWidget);
  });

  testWidgets('App has correct theme and structure', (WidgetTester tester) async {
    await tester.pumpWidget(const MusicAIGeneratorApp());
    await tester.pumpAndSettle();

    // Verify app structure
    expect(find.byType(CupertinoApp), findsOneWidget);
    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(find.byType(CupertinoSlider), findsOneWidget);
    expect(find.byType(CupertinoButton), findsAtLeastNWidgets(1));
  });
}
