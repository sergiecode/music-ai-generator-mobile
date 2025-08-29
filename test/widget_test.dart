// This is a basic Flutter widget test for Music AI Generator Mobile
// Created by Sergie Code

import 'package:flutter_test/flutter_test.dart';

import 'package:music_ai_generator_mobile/main.dart';

void main() {
  testWidgets('Music AI Generator app launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MusicAIGeneratorApp());

    // Verify that the app contains the expected text
    expect(find.text('Music AI Generator'), findsOneWidget);
    expect(find.text('Created by Sergie Code'), findsOneWidget);
    
    // Verify that the main UI elements are present
    expect(find.text('Music Description'), findsOneWidget);
    expect(find.text('🎵 Generate Music'), findsOneWidget);
  });
}
