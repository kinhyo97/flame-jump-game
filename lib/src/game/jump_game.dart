// Level, Player, 입력 시스템을 조립하고 게임 전체 흐름을 시작하는 루트 게임 파일.
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../core/assets.dart';
import '../core/constants.dart';
import '../ui/hud.dart';
import '../entities/player/player.dart';
import '../systems/audio_system.dart';
import '../systems/collision_system.dart';
import '../systems/input_system.dart';
import '../world/level.dart';

class JumpGame extends FlameGame with KeyboardEvents {
  static const clearOverlayId = 'clear-overlay';

  JumpGame() : inputSystem = InputSystem(), collisionSystem = CollisionSystem();

  final InputSystem inputSystem;
  final CollisionSystem collisionSystem;
  final AudioSystem audioSystem = AudioSystem();

  late final Level level;
  late final Player player;
  late final Hud hud;
  late Vector2 _respawnPosition;
  int coinsCollected = 0;
  bool isLevelCleared = false;

  @override
  Color backgroundColor() => const Color(GameConstants.backgroundColor);

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(
      width: GameConstants.resolution.x,
      height: GameConstants.resolution.y,
    );

    level = Level();
    player = Player();
    hud = Hud();
    _respawnPosition = PlayerConstants.spawn.clone();

    await world.add(level);
    await world.add(player);
    await camera.viewport.add(hud);

    await audioSystem.load(
      jumpAsset: AudioAssets.jump,
      coinAsset: AudioAssets.coin,
      clearAsset: AudioAssets.clear,
      hurtAsset: AudioAssets.hurt,
    );

    camera.setBounds(
      Rect.fromLTWH(
        0,
        0,
        level.worldWidth,
        level.worldHeight,
      ).toFlameRectangle(),
      considerViewport: true,
    );
    camera.follow(
      player,
      horizontalOnly: true,
      maxSpeed: GameConstants.cameraFollowSpeed,
      snap: true,
    );
    _syncHud();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isLevelCleared) {
      return;
    }

    _collectCoins();
    _checkCheckpoints();
    _checkSprings();
    _checkHazards();
    _updateExitState();
    _checkLevelClear();
    inputSystem.resetFrameInput();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isPressed = event is KeyDownEvent || event is KeyRepeatEvent;
    final isReleased = event is KeyUpEvent;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      inputSystem.setMoveLeft(isPressed && !isReleased);
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      inputSystem.setMoveRight(isPressed && !isReleased);
    }

    if (isPressed &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.arrowUp ||
            event.logicalKey == LogicalKeyboardKey.keyW)) {
      inputSystem.queueJump();
    }

    return KeyEventResult.handled;
  }

  void _collectCoins() {
    for (final coin in level.coins) {
      if (coin.collected) {
        continue;
      }

      final coinBounds = Rect.fromLTWH(
        coin.position.x,
        coin.position.y,
        coin.size.x,
        coin.size.y,
      );

      if (!player.bounds.overlaps(coinBounds)) {
        continue;
      }

      coin.collected = true;
      coin.removeFromParent();
      coinsCollected++;
      unawaited(audioSystem.play(SoundEffect.coin));
      hud.setCoinCount(coinsCollected);
    }
  }

  void _updateExitState() {
    if (level.exitGate.isOpen) {
      return;
    }

    final remainingCoins = level.totalCoins - coinsCollected;
    if (remainingCoins > 0) {
      hud.setExitLocked(remainingCoins);
      return;
    }

    level.exitGate.openGate();
    hud.setExitOpen();
  }

  void _checkLevelClear() {
    if (!level.exitGate.isOpen) {
      return;
    }

    if (!player.bounds.overlaps(level.exitGate.bounds)) {
      return;
    }

    isLevelCleared = true;
    hud.setLevelCleared();
    unawaited(audioSystem.play(SoundEffect.clear));
    pauseEngine();
    overlays.add(clearOverlayId);
  }

  void resetLevel() {
    coinsCollected = 0;
    isLevelCleared = false;
    _respawnPosition = PlayerConstants.spawn.clone();
    level.resetState();
    player.reset();
    camera.viewfinder.position = player.position.clone();
    _syncHud();
    overlays.remove(clearOverlayId);
    resumeEngine();
  }

  void _syncHud() {
    hud.setCoinCount(coinsCollected);
    hud.setExitLocked(level.totalCoins - coinsCollected);
  }

  void playJumpSound() {
    unawaited(audioSystem.play(SoundEffect.jump));
  }

  void _checkHazards() {
    for (final spike in level.spikes) {
      if (!player.bounds.overlaps(spike.bounds)) {
        continue;
      }

      _respawnPlayer();
      return;
    }

    for (final saw in level.saws) {
      if (!player.bounds.overlaps(saw.bounds)) {
        continue;
      }

      _respawnPlayer();
      return;
    }
  }

  void _respawnPlayer() {
    player.resetTo(_respawnPosition);
    camera.viewfinder.position = player.position.clone();
    unawaited(audioSystem.play(SoundEffect.hurt));
  }

  void _checkCheckpoints() {
    for (final checkpoint in level.checkpoints) {
      if (!player.bounds.overlaps(checkpoint.bounds)) {
        continue;
      }

      if (checkpoint.isActive) {
        return;
      }

      for (final otherCheckpoint in level.checkpoints) {
        if (identical(otherCheckpoint, checkpoint)) {
          continue;
        }
        otherCheckpoint.deactivate();
      }

      checkpoint.activate();
      _respawnPosition = checkpoint.respawnPosition.clone();
      return;
    }
  }

  void _checkSprings() {
    final playerBounds = player.bounds;

    for (final spring in level.springs) {
      if (!playerBounds.overlaps(spring.bounds)) {
        continue;
      }

      final playerBottom = playerBounds.bottom;
      final springTop = spring.bounds.top;
      final playerWasAboveSpring = playerBottom - player.velocity.y * (1 / 60) <= springTop + 8;

      if (player.velocity.y < 0 || !playerWasAboveSpring) {
        continue;
      }

      player.position.y = springTop - player.size.y;
      player.bounce(PlayerConstants.springJumpSpeed);
      spring.trigger();
      return;
    }
  }

  @override
  void onRemove() {
    unawaited(audioSystem.dispose());
    super.onRemove();
  }
}
