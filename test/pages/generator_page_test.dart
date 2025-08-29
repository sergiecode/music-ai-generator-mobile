import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_ai_generator_mobile/pages/generator_page.dart';

void main() {
  group('GeneratorPage Tests', () {
    testWidgets('should render basic UI components', (WidgetTester tester) async {
      await tester.pumpWidget(const CupertinoApp(home: GeneratorPage()));
      await tester.pumpAndSettle();

      // Test that essential widgets are present
      expect(find.text('Music AI Generator'), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsOneWidget);
      expect(find.byType(CupertinoSlider), findsOneWidget);
      expect(find.byType(CupertinoButton), findsAtLeastNWidgets(1));
      expect(find.text('Duration: 30 seconds'), findsOneWidget);
    });

    testWidgets('should have correct initial values', (WidgetTester tester) async {
      await tester.pumpWidget(const CupertinoApp(home: GeneratorPage()));
      await tester.pumpAndSettle();

      // Check slider properties
      final slider = tester.widget<CupertinoSlider>(find.byType(CupertinoSlider));
      expect(slider.min, equals(5.0));
      expect(slider.max, equals(300.0));
      expect(slider.value, equals(30.0));

      // Check text field properties
      final textField = tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
      expect(textField.maxLines, equals(3));
      expect(textField.placeholder, contains('Describe the music'));
    });

    testWidgets('should have proper navigation structure', (WidgetTester tester) async {
      await tester.pumpWidget(const CupertinoApp(home: GeneratorPage()));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display generate button', (WidgetTester tester) async {
      await tester.pumpWidget(const CupertinoApp(home: GeneratorPage()));
      await tester.pumpAndSettle();

      expect(find.text('🎵 Generate Music'), findsOneWidget);
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(const CupertinoApp(home: GeneratorPage()));
      await tester.pumpAndSettle();

      // Basic accessibility check - widgets should be findable
      expect(find.byType(CupertinoTextField), findsOneWidget);
      expect(find.byType(CupertinoSlider), findsOneWidget);
      expect(find.byType(CupertinoButton), findsAtLeastNWidgets(1));
    });
  });
}
