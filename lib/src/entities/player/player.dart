// 플레이어의 이동, 점프, 중력, 착지와 상태 전이를 처리하는 핵심 엔티티 파일.
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import '../../core/assets.dart';
import '../../core/constants.dart';
import '../../game/jump_game.dart';
import '../base/actor.dart';
import '../objects/disappearing_platform.dart';
import 'player_state.dart';

class Player extends Actor with HasGameReference<JumpGame> {
  static const double _hitboxInsetX = 6;
  static const double _hitboxInsetTop = 10;
  static const double _hitboxInsetBottom = 4;
  static const double _respawnRiseDistance = 18;
  static const double _respawnStartScale = 0.86;
  static const double _respawnBlinkInterval = 0.08;
  static const double _invincibleBlinkInterval = 0.1;

  Player()
    : state = PlayerState.idle,
      _jumpCount = 0,
      super(
        position: PlayerConstants.spawn.clone(),
        size: PlayerConstants.size.clone(),
      );

  PlayerState state;
  bool isOnGround = false;
  bool facingLeft = false;
  Vector2 _groundDelta = Vector2.zero();
  int _jumpCount;
  static const int _maxJumpCount = 2;

  SpriteAnimationGroupComponent<PlayerState>? _sprite;
  late final Map<PlayerState, SpriteAnimation> _animations;
  Vector2 _previousPosition = Vector2.zero();
  bool _isRespawning = false;
  double _respawnTimer = 0;
  double _respawnDuration = 0;
  late Vector2 _respawnTargetPosition = Vector2.zero();
  bool _isInvincible = false;
  double _invincibleTimer = 0;

  bool get isRespawning => _isRespawning;
  bool get isInvincible => _isInvincible;
  double get invincibleTimeRemaining => _invincibleTimer;

  @override
  Future<void> onLoad() async {
    _animations = {
      PlayerState.idle: SpriteAnimation.spriteList([
        await game.loadSprite(ImageAssets.playerGreenIdle),
      ], stepTime: 1),
      PlayerState.run: SpriteAnimation.spriteList([
        await game.loadSprite(ImageAssets.playerGreenWalkA),
        await game.loadSprite(ImageAssets.playerGreenWalkB),
      ], stepTime: 0.12),
      PlayerState.jump: SpriteAnimation.spriteList([
        await game.loadSprite(ImageAssets.playerGreenJump),
      ], stepTime: 1),
      PlayerState.fall: SpriteAnimation.spriteList([
        await game.loadSprite(ImageAssets.playerGreenJump),
      ], stepTime: 1),
    };

    _sprite = SpriteAnimationGroupComponent<PlayerState>(
      position: size / 2,
      size: size,
      anchor: Anchor.center,
      animations: _animations,
      current: PlayerState.idle,
    );

    add(_sprite!);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateInvincibility(dt);

    if (_isRespawning) {
      _updateRespawnSequence(dt);
      return;
    }

    final input = game.inputSystem;

    _applyHorizontalMovement(input.horizontal, dt);
    _applyJump(input.jumpPressed);
    _applyGravity(dt);
    _move(dt);
    _resolveWallSideCollisions();
    _resolveFloorCollision();
    _updateState(input.horizontal);
    _updateFacingDirection(input.horizontal);
    _updateSprite();
  }

  void _applyHorizontalMovement(double direction, double dt) {
    if (direction != 0) {
      velocity.x += direction * PlayerConstants.runAcceleration * dt;
      velocity.x = velocity.x.clamp(
        -PlayerConstants.maxRunSpeed,
        PlayerConstants.maxRunSpeed,
      );
      return;
    }

    final deceleration = PlayerConstants.runDeceleration * dt;
    if (velocity.x.abs() <= deceleration) {
      velocity.x = 0;
      return;
    }

    velocity.x -= velocity.x.sign * deceleration;
  }

  void _applyJump(bool jumpPressed) {
    if (!jumpPressed || _jumpCount >= _maxJumpCount) {
      return;
    }

    velocity.y = -PlayerConstants.jumpSpeed;
    isOnGround = false;
    _jumpCount++;
    game.playJumpSound();
  }

  void _applyGravity(double dt) {
    final gravityMultiplier = velocity.y > 0
        ? PlayerConstants.fallGravityMultiplier
        : 1.0;

    velocity.y += PlayerConstants.gravity * gravityMultiplier * dt;
    velocity.y = velocity.y.clamp(
      double.negativeInfinity,
      PlayerConstants.maxFallSpeed,
    );
  }

  void _move(double dt) {
    _previousPosition = position.clone();
    position += velocity * dt;
    if (isOnGround) {
      position += _groundDelta;
    }
  }

  void _resolveFloorCollision() {
    isOnGround = false;
    _groundDelta.setZero();

    final previousBottom = _previousPosition.y + size.y;
    final currentBottom = position.y + size.y;
    final currentLeft = position.x;
    final currentRight = position.x + size.x;

    double? landingTop;
    Vector2? landingDelta;
    DisappearingPlatform? landingDisappearingPlatform;

    for (final surface in game.level.surfaces) {
      final overlapsHorizontally =
          currentRight > surface.left && currentLeft < surface.right;
      final crossedSurfaceTop =
          previousBottom <= surface.top && currentBottom >= surface.top;

      if (!overlapsHorizontally || !crossedSurfaceTop || velocity.y < 0) {
        continue;
      }

      if (landingTop == null || surface.top < landingTop) {
        landingTop = surface.top;
        landingDelta = Vector2.zero();
      }
    }

    for (final wall in game.level.walls) {
      final overlapsHorizontally =
          currentRight > wall.left && currentLeft < wall.right;
      final crossedSurfaceTop =
          previousBottom <= wall.top && currentBottom >= wall.top;

      if (!overlapsHorizontally || !crossedSurfaceTop || velocity.y < 0) {
        continue;
      }

      if (landingTop == null || wall.top < landingTop) {
        landingTop = wall.top;
        landingDelta = Vector2.zero();
        landingDisappearingPlatform = null;
      }
    }

    for (final platform in game.level.movingPlatforms) {
      final platformLeft = platform.position.x;
      final platformRight = platform.position.x + platform.size.x;
      final platformTop = platform.position.y;
      final overlapsHorizontally =
          currentRight > platformLeft && currentLeft < platformRight;
      final crossedSurfaceTop =
          previousBottom <= platformTop && currentBottom >= platformTop;

      if (!overlapsHorizontally || !crossedSurfaceTop || velocity.y < 0) {
        continue;
      }

      if (landingTop == null || platformTop < landingTop) {
        landingTop = platformTop;
        landingDelta = platform.delta.clone();
      }
    }

    for (final platform in game.level.verticalMovingPlatforms) {
      final overlapsHorizontally =
          currentRight > platform.left && currentLeft < platform.right;
      final crossedSurfaceTop =
          previousBottom <= platform.top && currentBottom >= platform.top;

      if (!overlapsHorizontally || !crossedSurfaceTop || velocity.y < 0) {
        continue;
      }

      if (landingTop == null || platform.top < landingTop) {
        landingTop = platform.top;
        landingDelta = platform.delta.clone();
        landingDisappearingPlatform = null;
      }
    }

    for (final platform in game.level.disappearingPlatforms) {
      if (!platform.isSolid) {
        continue;
      }

      final overlapsHorizontally =
          currentRight > platform.left && currentLeft < platform.right;
      final crossedSurfaceTop =
          previousBottom <= platform.top && currentBottom >= platform.top;

      if (!overlapsHorizontally || !crossedSurfaceTop || velocity.y < 0) {
        continue;
      }

      if (landingTop == null || platform.top < landingTop) {
        landingTop = platform.top;
        landingDelta = Vector2.zero();
        landingDisappearingPlatform = platform;
      }
    }

    if (landingTop == null) {
      return;
    }

    position.y = landingTop - size.y;
    if (landingDelta != null) {
      _groundDelta = landingDelta;
    }
    velocity.y = 0;
    isOnGround = true;
    _jumpCount = 0;
    landingDisappearingPlatform?.onPlayerLanded();
  }

  void _updateState(double direction) {
    if (!isOnGround) {
      state = velocity.y < 0 ? PlayerState.jump : PlayerState.fall;
      return;
    }

    if (direction != 0 || velocity.x.abs() > 1) {
      state = PlayerState.run;
      return;
    }

    state = PlayerState.idle;
  }

  void _updateFacingDirection(double direction) {
    if (direction == 0) {
      return;
    }

    facingLeft = direction < 0;
  }

  void _resolveWallSideCollisions() {
    final previousLeft = _previousPosition.x;
    final previousRight = _previousPosition.x + size.x;
    final currentLeft = position.x;
    final currentRight = position.x + size.x;
    final currentTop = position.y;
    final currentBottom = position.y + size.y;

    for (final wall in game.level.walls) {
      final overlapsVertically =
          currentBottom > wall.top && currentTop < wall.bottom;

      if (!overlapsVertically) {
        continue;
      }

      final hitFromLeft =
          velocity.x > 0 &&
          previousRight <= wall.left &&
          currentRight > wall.left;
      if (hitFromLeft) {
        position.x = wall.left - size.x;
        velocity.x = 0;
        continue;
      }

      final hitFromRight =
          velocity.x < 0 &&
          previousLeft >= wall.right &&
          currentLeft < wall.right;
      if (hitFromRight) {
        position.x = wall.right;
        velocity.x = 0;
      }
    }
  }

  void _updateSprite() {
    final sprite = _sprite;
    if (sprite == null) {
      return;
    }

    sprite.current = _animations.containsKey(state) ? state : PlayerState.idle;
    sprite.scale.x = facingLeft ? -1 : 1;
    sprite.scale.y = 1;
    sprite.opacity = _isInvincible && _shouldBlinkForInvincibility() ? 0.45 : 1;
  }

  void reset() {
    resetTo(game.level.playerSpawn);
  }

  void resetTo(Vector2 spawnPosition) {
    position = spawnPosition.clone();
    velocity.setZero();
    _previousPosition = position.clone();
    _groundDelta.setZero();
    _isRespawning = false;
    _respawnTimer = 0;
    _respawnDuration = 0;
    _respawnTargetPosition = spawnPosition.clone();
    state = PlayerState.idle;
    isOnGround = false;
    facingLeft = false;
    _jumpCount = 0;
    _updateSprite();
  }

  void activateInvincibility(double duration) {
    _isInvincible = true;
    _invincibleTimer = duration;
    _updateSprite();
  }

  void startRespawnSequence(Vector2 spawnPosition, double duration) {
    resetTo(spawnPosition);
    _isRespawning = true;
    _respawnTimer = 0;
    _respawnDuration = duration;
    _respawnTargetPosition = spawnPosition.clone();
    _applyRespawnVisuals(0);
  }

  void _updateRespawnSequence(double dt) {
    _respawnTimer += dt;
    final progress = (_respawnTimer / _respawnDuration).clamp(0.0, 1.0);
    _applyRespawnVisuals(progress);

    if (progress < 1) {
      return;
    }

    resetTo(_respawnTargetPosition);
  }

  void _applyRespawnVisuals(double progress) {
    final sprite = _sprite;
    if (sprite == null) {
      return;
    }

    final riseOffset = (1 - progress) * _respawnRiseDistance;
    position = Vector2(
      _respawnTargetPosition.x,
      _respawnTargetPosition.y - riseOffset,
    );
    _previousPosition = position.clone();

    final visualScale =
        _respawnStartScale + ((1 - _respawnStartScale) * progress);
    sprite.scale.x = facingLeft ? -visualScale : visualScale;
    sprite.scale.y = visualScale;

    final blinkFrame = (_respawnTimer / _respawnBlinkInterval).floor();
    sprite.opacity = blinkFrame.isEven ? 0.45 : 1;
    sprite.current = PlayerState.idle;
  }

  void _updateInvincibility(double dt) {
    if (!_isInvincible) {
      return;
    }

    _invincibleTimer -= dt;
    if (_invincibleTimer <= 0) {
      _invincibleTimer = 0;
      _isInvincible = false;
    }
  }

  bool _shouldBlinkForInvincibility() {
    final blinkFrame = (_invincibleTimer / _invincibleBlinkInterval).floor();
    return blinkFrame.isEven;
  }

  void bounce(double jumpSpeed) {
    velocity.y = -jumpSpeed;
    isOnGround = false;
    _jumpCount = 1;
    game.playJumpSound();
  }

  Rect get bounds => Rect.fromLTWH(
    position.x + _hitboxInsetX,
    position.y + _hitboxInsetTop,
    size.x - (_hitboxInsetX * 2),
    size.y - _hitboxInsetTop - _hitboxInsetBottom,
  );
}
