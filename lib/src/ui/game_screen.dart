import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../entities/player/player_skin.dart';
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
  var _isApplyingSkin = false;
  var _selectedSkin = PlayerSkin.classic;

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
        _selectedSkin = _game.selectedSkin;
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
                          width: 420,
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
                                '캐릭터를 선택하고 게임을 시작하세요.',
                                style: TextStyle(
                                  color: Color(0xFFD6E2F0),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: availablePlayerSkins
                                    .map(
                                      (skin) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: _PlayerSkinCard(
                                            skin: skin,
                                            isSelected:
                                                _selectedSkin == skin,
                                            onTap: _isApplyingSkin
                                                ? null
                                                : () => _selectSkin(skin),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _isApplyingSkin
                                      ? null
                                      : () {
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
                                  child: Text(
                                    _isApplyingSkin
                                        ? 'Applying...'
                                        : 'Game Start!',
                                    style: const TextStyle(
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

  Future<void> _selectSkin(PlayerSkin skin) async {
    if (_selectedSkin == skin || _isApplyingSkin) {
      return;
    }

    setState(() {
      _selectedSkin = skin;
      _isApplyingSkin = true;
    });

    await _game.setPlayerSkin(skin);

    if (!mounted) {
      return;
    }

    setState(() {
      _isApplyingSkin = false;
    });
  }
}

class _PlayerSkinCard extends StatelessWidget {
  const _PlayerSkinCard({
    required this.skin,
    required this.isSelected,
    required this.onTap,
  });

  final PlayerSkin skin;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0x33FFE082)
                : const Color(0xFF182234),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFE082)
                  : const Color(0x335A6C84),
              width: isSelected ? 2 : 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: const Color(0xFF0F1724),
                    child: _PlayerSkinPreview(skin: skin),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                skin.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                skin.subtitle,
                style: const TextStyle(
                  color: Color(0xFFD6E2F0),
                  fontSize: 12,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerSkinPreview extends StatelessWidget {
  const _PlayerSkinPreview({required this.skin});

  final PlayerSkin skin;

  @override
  Widget build(BuildContext context) {
    if (skin == PlayerSkin.bazzi || skin == PlayerSkin.whale) {
      return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 96,
          height: 96,
          child: OverflowBox(
            minWidth: 0,
            minHeight: 0,
            maxWidth: skin == PlayerSkin.whale ? 192 : 192,
            maxHeight: 96,
            alignment: Alignment.centerLeft,
            child: Image.asset(
              skin.previewAssetPath,
              width: 192,
              height: 96,
              fit: BoxFit.fill,
              alignment: Alignment.centerLeft,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        skin.previewAssetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}
