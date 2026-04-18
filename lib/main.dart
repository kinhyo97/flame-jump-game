// Flutter 앱을 Flame의 JumpGame 진입점으로 연결하는 시작 파일.
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'src/game/jump_game.dart';
import 'src/ui/clear_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget<JumpGame>(
          autofocus: true,
          game: JumpGame(),
          overlayBuilderMap: {
            JumpGame.clearOverlayId: (context, game) {
              return ClearOverlay(game: game);
            },
          },
        ),
      ),
    ),
  );
}
