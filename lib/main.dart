import 'package:flutter/cupertino.dart';
import 'pages/generator_page.dart';

void main() {
  runApp(const MusicAIGeneratorApp());
}

/// Main application widget
/// Music AI Generator Mobile - Created by Sergie Code
class MusicAIGeneratorApp extends StatelessWidget {
  const MusicAIGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Music AI Generator',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
      ),
      home: const GeneratorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
