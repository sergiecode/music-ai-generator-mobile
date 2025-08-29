import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_ai_generator_mobile/main.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('should load app successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const MusicAIGeneratorApp());
      await tester.pumpAndSettle();

      // Verify app loads with correct theme
      expect(find.byType(CupertinoApp), findsOneWidget);
      expect(find.text('Music AI Generator'), findsOneWidget);
    });

    testWidgets('should have proper theme configuration', (WidgetTester tester) async {
      await tester.pumpWidget(const MusicAIGeneratorApp());
      await tester.pumpAndSettle();

      final app = tester.widget<CupertinoApp>(find.byType(CupertinoApp));
      expect(app.theme, isNotNull);
      expect(app.theme!.brightness, equals(Brightness.light));
    });

    testWidgets('should display main UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MusicAIGeneratorApp());
      await tester.pumpAndSettle();

      // Check main UI components are present
      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsOneWidget);
      expect(find.byType(CupertinoSlider), findsOneWidget);
      expect(find.byType(CupertinoButton), findsAtLeastNWidgets(1));
    });

    testWidgets('should render without errors', (WidgetTester tester) async {
      // Test that app can be created and rendered without throwing
      await tester.pumpWidget(const MusicAIGeneratorApp());
      await tester.pump(); // Single pump to catch immediate errors
      await tester.pumpAndSettle(); // Settle to catch async errors

      // If we get here, no errors were thrown during rendering
      expect(find.byType(CupertinoApp), findsOneWidget);
    });
  });
}
