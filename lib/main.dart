import 'package:flutter/material.dart';

import 'src/ui/editor_screen.dart';
import 'src/ui/game_screen.dart';
import 'src/ui/map_test_screen.dart';
import 'src/world/editor_draft_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JumpGameApp());
}

class JumpGameApp extends StatelessWidget {
  const JumpGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialUri = Uri.base;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _buildScreen(initialUri),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => _buildScreen(uri),
        );
      },
    );
  }

  Widget _buildScreen(Uri uri) {
    switch (uri.path) {
      case '/editor':
        return const EditorScreen();
      case '/map-test':
        return const MapTestScreen();
      case '/play':
        return GameScreen(
          initialStageIndex: _parseStageIndex(uri),
          isMapTestStage: _isMapTestStage(uri),
          shortcutLabel: 'Map Test',
          shortcutRoute: '/map-test',
        );
      case '/play-custom':
        final draftLevel = EditorDraftStore.currentLevel;
        if (draftLevel == null) {
          return const EditorScreen();
        }
        return GameScreen(
          initialStageIndex: 0,
          customStageData: draftLevel,
          shortcutLabel: 'Editor',
          shortcutRoute: '/editor',
        );
      case '/':
      default:
        return const GameScreen(initialStageIndex: 0);
    }
  }

  int _parseStageIndex(Uri uri) {
    final stageNumber = int.tryParse(uri.queryParameters['stage'] ?? '') ?? 1;
    return (stageNumber - 1).clamp(0, 999);
  }

  bool _isMapTestStage(Uri uri) {
    final rawValue = uri.queryParameters['mapTest'];
    return rawValue == '1' || rawValue == 'true';
  }
}
