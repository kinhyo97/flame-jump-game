// 플레이어의 이동, 점프, 중력, 착지와 상태 전이를 처리하는 핵심 엔티티 파일.
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import '../../core/assets.dart';
import '../../core/constants.dart';
import '../../game/jump_game.dart';
import '../base/actor.dart';
import 'player_state.dart';

class Player extends Actor with HasGameReference<JumpGame> {
  Player()
    : state = PlayerState.idle,
      super(
        position: PlayerConstants.spawn.clone(),
        size: PlayerConstants.size.clone(),
      );

  PlayerState state;
  bool isOnGround = false;
  bool facingLeft = false;
  Vector2 _groundDelta = Vector2.zero();

  SpriteAnimationGroupComponent<PlayerState>? _sprite;
  late final Map<PlayerState, SpriteAnimation> _animations;
  Vector2 _previousPosition = Vector2.zero();

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

    final input = game.inputSystem;

    _applyHorizontalMovement(input.horizontal, dt);
    _applyJump(input.jumpPressed);
    _applyGravity(dt);
    _move(dt);
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
    if (!jumpPressed || !isOnGround) {
      return;
    }

    velocity.y = -PlayerConstants.jumpSpeed;
    isOnGround = false;
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

    if (landingTop == null) {
      return;
    }

    position.y = landingTop - size.y;
    if (landingDelta != null) {
      _groundDelta = landingDelta;
    }
    velocity.y = 0;
    isOnGround = true;
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

  void _updateSprite() {
    final sprite = _sprite;
    if (sprite == null) {
      return;
    }

    sprite.current = _animations.containsKey(state) ? state : PlayerState.idle;
    sprite.scale.x = facingLeft ? -1 : 1;
  }

  void reset() {
    resetTo(PlayerConstants.spawn);
  }

  void resetTo(Vector2 spawnPosition) {
    position = spawnPosition.clone();
    velocity.setZero();
    _previousPosition = position.clone();
    _groundDelta.setZero();
    state = PlayerState.idle;
    isOnGround = false;
    facingLeft = false;
    _updateSprite();
  }

  void bounce(double jumpSpeed) {
    velocity.y = -jumpSpeed;
    isOnGround = false;
    game.playJumpSound();
  }

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
