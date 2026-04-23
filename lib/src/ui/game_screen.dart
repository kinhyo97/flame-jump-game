import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/jump_game.dart';
import '../world/level_models.dart';
import 'clear_overlay.dart';
import 'game_over_overlay.dart';
import 'mobile_controls_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.initialStageIndex,
    this.isMapTestStage = false,
    this.customStageData,
    this.shortcutLabel,
    this.shortcutRoute,
  });

  final int initialStageIndex;
  final bool isMapTestStage;
  final LevelData? customStageData;
  final String? shortcutLabel;
  final String? shortcutRoute;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final JumpGame _game;
  var _isLoaded = false;
  var _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _game = JumpGame(
      initialStageIndex: widget.initialStageIndex,
      isMapTestStage: widget.isMapTestStage,
      customStageData: widget.customStageData,
      startPaused: true,
    );
    _game.bootReady.then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<JumpGame>(
            autofocus: true,
            game: _game,
            initialActiveOverlays: const [JumpGame.mobileControlsOverlayId],
            overlayBuilderMap: {
              JumpGame.clearOverlayId: (context, game) {
                return ClearOverlay(game: game);
              },
              JumpGame.gameOverOverlayId: (context, game) {
                return GameOverOverlay(game: game);
              },
              JumpGame.mobileControlsOverlayId: (context, game) {
                return MobileControlsOverlay(game: game);
              },
            },
          ),
          if (!_hasStarted)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xE610151F),
                child: Center(
                  child: _isLoaded
                      ? Container(
                          width: 360,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF223047),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFE082),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Ready To Play',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '모든 에셋 로딩이 끝났습니다.',
                                style: TextStyle(
                                  color: Color(0xFFD6E2F0),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () {
                                    _game.startGameplay();
                                    setState(() {
                                      _hasStarted = true;
                                    });
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC857),
                                    foregroundColor: const Color(0xFF1A2233),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text(
                                    'Game Start!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFC857),
                                strokeWidth: 4,
                              ),
                            ),
                            SizedBox(height: 18),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          if (widget.shortcutLabel != null && widget.shortcutRoute != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(widget.shortcutRoute!);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xCCFFFFFF),
                      foregroundColor: const Color(0xFF1A2233),
                    ),
                    child: Text(widget.shortcutLabel!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
