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
import '../world/levels_registry.dart';

class JumpGame extends FlameGame with KeyboardEvents {
  static const clearOverlayId = 'clear-overlay';
  static const gameOverOverlayId = 'game-over-overlay';
  static const mobileControlsOverlayId = 'mobile-controls';
  static const initialLives = 3;
  static const maxLives = initialLives;
  static const respawnLockDuration = 1.1;
  static const invincibilityDuration = 10.0;

  JumpGame({
    int initialStageIndex = 0,
    bool isMapTestStage = false,
    LevelData? customStageData,
    bool startPaused = true,
  })
    : _initialStageIndex = initialStageIndex,
      _isMapTestStage = isMapTestStage,
      _customStageData = customStageData,
      _startPaused = startPaused,
      _isMapTestHub = false,
      _onTestPortalEnter = null,
      inputSystem = InputSystem(),
      collisionSystem = CollisionSystem();

  JumpGame.mapTestHub({required ValueChanged<int> onTestPortalEnter})
    : _initialStageIndex = 0,
      _isMapTestStage = false,
      _customStageData = null,
      _startPaused = false,
      _isMapTestHub = true,
      _onTestPortalEnter = onTestPortalEnter,
      inputSystem = InputSystem(),
      collisionSystem = CollisionSystem();

  final int _initialStageIndex;
  final bool _isMapTestStage;
  final LevelData? _customStageData;
  final bool _startPaused;
  final bool _isMapTestHub;
  final ValueChanged<int>? _onTestPortalEnter;
  final InputSystem inputSystem;
  final CollisionSystem collisionSystem;
  final AudioSystem audioSystem = AudioSystem();
  final Completer<void> _bootCompleter = Completer<void>();

  late final Level level;
  late final Player player;
  late final Hud hud;
  late Vector2 _respawnPosition;
  int coinsCollected = 0;
  int livesRemaining = initialLives;
  bool isLevelCleared = false;
  bool isGameOver = false;
  bool _isClearActionInProgress = false;
  bool _isPortalTransitionInProgress = false;

  bool get shouldRetryCurrentStageOnClear =>
      _isMapTestStage || _customStageData != null;
  Future<void> get bootReady => _bootCompleter.future;

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

    await world.add(level);
    await world.add(player);

    if (!_isMapTestHub) {
      await camera.viewport.add(hud);
    }

    if (_isMapTestHub) {
      await level.loadHubStage(mapTestHubLevel);
    } else if (_customStageData != null) {
      await level.loadCustomStage(_customStageData);
    } else {
      final initialStageIndex = _initialStageIndex.clamp(0, level.totalStages - 1);
      await level.loadStage(initialStageIndex);
    }
    _respawnPosition = level.playerSpawn;

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
    player.resetTo(_respawnPosition);
    if (!_isMapTestHub) {
      _syncHud();
    }
    if (_startPaused) {
      pauseEngine();
    }
    if (!_bootCompleter.isCompleted) {
      _bootCompleter.complete();
    }
  }

  void startGameplay() {
    resumeEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isMapTestHub) {
      hud.setInvincibilityTime(player.invincibleTimeRemaining);
    }

    if (isLevelCleared || isGameOver) {
      inputSystem.resetFrameInput();
      return;
    }

    final playerBounds = player.bounds;

    if (_isMapTestHub) {
      _checkTestPortals(playerBounds);
      inputSystem.resetFrameInput();
      return;
    }

    if (player.isRespawning) {
      inputSystem.resetFrameInput();
      return;
    }

    _collectCoins(playerBounds);
    _collectHearts(playerBounds);
    _collectStars(playerBounds);
    _checkCheckpoints(playerBounds);
    _checkSprings(playerBounds);
    _checkHazards(playerBounds);
    if (_checkOutOfBounds(playerBounds)) {
      inputSystem.resetFrameInput();
      return;
    }
    _updateExitState();
    _checkLevelClear(playerBounds);
    inputSystem.resetFrameInput();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isPressed = event is KeyDownEvent || event is KeyRepeatEvent;
    final isReleased = event is KeyUpEvent;
    final isJumpKey = event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW;

    if (isLevelCleared && event is KeyDownEvent && isJumpKey) {
      _handleClearOverlayAction();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      inputSystem.setMoveLeft(isPressed && !isReleased);
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      inputSystem.setMoveRight(isPressed && !isReleased);
    }

    if (isPressed && isJumpKey) {
      inputSystem.queueJump();
    }

    return KeyEventResult.handled;
  }

  void _collectCoins(Rect playerBounds) {
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

      if (!playerBounds.overlaps(coinBounds)) {
        continue;
      }

      coin.collected = true;
      coin.removeFromParent();
      coinsCollected++;
      unawaited(audioSystem.play(SoundEffect.coin));
      hud.setCoinCount(coinsCollected);
    }
  }

  void _collectHearts(Rect playerBounds) {
    if (livesRemaining >= maxLives) {
      return;
    }

    for (final heart in level.hearts) {
      if (heart.collected) {
        continue;
      }

      final heartBounds = Rect.fromLTWH(
        heart.position.x,
        heart.position.y,
        heart.size.x,
        heart.size.y,
      );

      if (!playerBounds.overlaps(heartBounds)) {
        continue;
      }

      heart.collected = true;
      heart.removeFromParent();
      livesRemaining = (livesRemaining + 1).clamp(0, maxLives);
      hud.setLivesCount(livesRemaining);
      unawaited(audioSystem.play(SoundEffect.coin));
    }
  }

  void _collectStars(Rect playerBounds) {
    for (final star in level.stars) {
      if (star.collected) {
        continue;
      }

      final starBounds = Rect.fromLTWH(
        star.position.x,
        star.position.y,
        star.size.x,
        star.size.y,
      );

      if (!playerBounds.overlaps(starBounds)) {
        continue;
      }

      star.collected = true;
      star.removeFromParent();
      player.activateInvincibility(invincibilityDuration);
      hud.setInvincibilityTime(player.invincibleTimeRemaining);
      unawaited(audioSystem.play(SoundEffect.clear));
    }
  }

  void _checkTestPortals(Rect playerBounds) {
    if (_isPortalTransitionInProgress) {
      return;
    }

    for (final portal in level.testPortals) {
      if (!playerBounds.overlaps(portal.bounds)) {
        continue;
      }

      _isPortalTransitionInProgress = true;
      pauseEngine();
      _onTestPortalEnter?.call(portal.targetStageIndex + 1);
      return;
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

  void _checkLevelClear(Rect playerBounds) {
    if (!level.exitGate.isOpen) {
      return;
    }

    if (!playerBounds.overlaps(level.exitGate.bounds)) {
      return;
    }

    isLevelCleared = true;
    hud.setLevelCleared();
    unawaited(audioSystem.play(SoundEffect.clear));
    pauseEngine();
    overlays.add(clearOverlayId);
  }

  Future<void> resetLevel() async {
    _isClearActionInProgress = true;
    coinsCollected = 0;
    livesRemaining = initialLives;
    isLevelCleared = false;
    isGameOver = false;
    await level.resetState();
    _respawnPosition = level.playerSpawn;
    player.reset();
    camera.viewfinder.position = player.position.clone();
    _syncHud();
    overlays.remove(clearOverlayId);
    overlays.remove(gameOverOverlayId);
    resumeEngine();
    _isClearActionInProgress = false;
  }

  Future<void> advanceToNextStage() async {
    if (_isMapTestStage) {
      await resetLevel();
      return;
    }

    if (!level.hasNextStage) {
      await resetLevel();
      return;
    }

    _isClearActionInProgress = true;
    coinsCollected = 0;
    isLevelCleared = false;
    isGameOver = false;
    await level.loadNextStage();
    _respawnPosition = level.playerSpawn;
    player.resetTo(_respawnPosition);
    camera.viewfinder.position = player.position.clone();
    _syncHud();
    overlays.remove(clearOverlayId);
    overlays.remove(gameOverOverlayId);
    resumeEngine();
    _isClearActionInProgress = false;
  }

  Future<void> restartFromFirstStage() async {
    if (_customStageData != null || _isMapTestStage || _isMapTestHub) {
      await resetLevel();
      return;
    }

    _isClearActionInProgress = true;
    coinsCollected = 0;
    livesRemaining = initialLives;
    isLevelCleared = false;
    isGameOver = false;
    await level.loadStage(0);
    _respawnPosition = level.playerSpawn;
    player.resetTo(_respawnPosition);
    camera.viewfinder.position = player.position.clone();
    _syncHud();
    overlays.remove(clearOverlayId);
    overlays.remove(gameOverOverlayId);
    resumeEngine();
    _isClearActionInProgress = false;
  }

  void _handleClearOverlayAction() {
    if (_isClearActionInProgress) {
      return;
    }

    _isClearActionInProgress = true;
    final action = shouldRetryCurrentStageOnClear || !level.hasNextStage
        ? resetLevel
        : advanceToNextStage;
    unawaited(action());
  }

  void _syncHud() {
    hud.setRound(level.currentStageNumber, level.totalStages);
    hud.setCoinCount(coinsCollected);
    hud.setLivesCount(livesRemaining);
    hud.setInvincibilityTime(player.invincibleTimeRemaining);
    hud.setExitLocked(level.totalCoins - coinsCollected);
  }

  void playJumpSound() {
    unawaited(audioSystem.play(SoundEffect.jump));
  }

  void _checkHazards(Rect playerBounds) {
    if (player.isInvincible) {
      hud.setInvincibilityTime(player.invincibleTimeRemaining);
      return;
    }

    for (final spike in level.spikes) {
      if (!playerBounds.overlaps(spike.bounds)) {
        continue;
      }

      _respawnPlayer();
      return;
    }

    for (final saw in level.saws) {
      if (!playerBounds.overlaps(saw.bounds)) {
        continue;
      }

      _respawnPlayer();
      return;
    }

    hud.setInvincibilityTime(player.invincibleTimeRemaining);
  }

  bool _checkOutOfBounds(Rect playerBounds) {
    const verticalBuffer = 120.0;
    const horizontalBuffer = 80.0;

    final fellBelowWorld = playerBounds.top > level.worldHeight + verticalBuffer;
    final leftOfWorld = playerBounds.right < -horizontalBuffer;
    final rightOfWorld = playerBounds.left > level.worldWidth + horizontalBuffer;

    if (!fellBelowWorld && !leftOfWorld && !rightOfWorld) {
      return false;
    }

    _respawnPlayer();
    return true;
  }

  void _respawnPlayer() {
    livesRemaining--;
    hud.setLivesCount(livesRemaining);

    if (livesRemaining <= 0) {
      isGameOver = true;
      pauseEngine();
      overlays.add(gameOverOverlayId);
      unawaited(audioSystem.play(SoundEffect.hurt));
      return;
    }

    final safeRespawnPosition = _findSafeRespawnPosition(_respawnPosition);
    player.startRespawnSequence(safeRespawnPosition, respawnLockDuration);
    camera.viewfinder.position = player.position.clone();
    unawaited(audioSystem.play(SoundEffect.hurt));
  }

  void _checkCheckpoints(Rect playerBounds) {
    for (final checkpoint in level.checkpoints) {
      if (!playerBounds.overlaps(checkpoint.bounds)) {
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
      _respawnPosition = _findSafeRespawnPosition(checkpoint.respawnPosition);
      return;
    }
  }

  Vector2 _findSafeRespawnPosition(Vector2 basePosition) {
    final horizontalOffsets = [0.0, 24.0, -24.0, 48.0, -48.0, 72.0, -72.0];

    for (var verticalStep = 0; verticalStep <= 6; verticalStep++) {
      final verticalOffset = verticalStep * 12.0;

      for (final horizontalOffset in horizontalOffsets) {
        final candidate = Vector2(
          basePosition.x + horizontalOffset,
          basePosition.y - verticalOffset,
        );

        if (_isSafeRespawnCandidate(candidate)) {
          return candidate;
        }
      }
    }

    return basePosition.clone();
  }

  bool _isSafeRespawnCandidate(Vector2 position) {
    final candidateBounds = Rect.fromLTWH(
      position.x,
      position.y,
      player.size.x,
      player.size.y,
    );

    if (candidateBounds.left < 0 ||
        candidateBounds.right > level.worldWidth ||
        candidateBounds.top < 0 ||
        candidateBounds.bottom > level.worldHeight) {
      return false;
    }

    for (final spike in level.spikes) {
      if (candidateBounds.overlaps(spike.bounds)) {
        return false;
      }
    }

    for (final saw in level.saws) {
      if (candidateBounds.overlaps(saw.bounds)) {
        return false;
      }
    }

    return true;
  }

  void _checkSprings(Rect playerBounds) {
    for (final spring in level.springs) {
      if (!playerBounds.overlaps(spring.bounds)) {
        continue;
      }

      final playerBottom = playerBounds.bottom;
      final springTop = spring.bounds.top;
      final playerWasAboveSpring =
          playerBottom - player.velocity.y * (1 / 60) <= springTop + 8;

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
