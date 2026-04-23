import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/jump_game.dart';
import 'clear_overlay.dart';
import 'mobile_controls_overlay.dart';

class MapTestScreen extends StatefulWidget {
  const MapTestScreen({super.key});

  @override
  State<MapTestScreen> createState() => _MapTestScreenState();
}

class _MapTestScreenState extends State<MapTestScreen> {
  late final JumpGame _game;

  @override
  void initState() {
    super.initState();
    _game = JumpGame.mapTestHub(
      onTestPortalEnter: (stageNumber) {
        if (!mounted) {
          return;
        }

        Navigator.of(
          context,
        ).pushReplacementNamed('/play?stage=$stageNumber&mapTest=1');
      },
    );
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
              JumpGame.mobileControlsOverlayId: (context, game) {
                return MobileControlsOverlay(game: game);
              },
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xCCFFFFFF),
                      foregroundColor: const Color(0xFF1A2233),
                    ),
                    child: const Text('Normal Game'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xCC1A2233),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x55FFE082)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Text(
                          'Map Test Hub: move to a door and enter it to jump straight into that round.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
