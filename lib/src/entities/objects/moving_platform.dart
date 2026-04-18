// 좌우로 왕복 이동하며 플레이어를 함께 실어 나르는 발판 오브젝트 파일.
import 'dart:math' as math;

import 'package:flame/components.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/game_entity.dart';

class MovingPlatform extends GameEntity with HasGameReference<JumpGame> {
  MovingPlatform({
    required super.position,
    required super.size,
    required this.startPosition,
    required this.travelDistance,
    required this.speed,
  });

  final Vector2 startPosition;
  final double travelDistance;
  final double speed;
  final Vector2 delta = Vector2.zero();

  double _elapsed = 0;
  late final SpriteComponent _sprite;

  @override
  Future<void> onLoad() async {
    final sprite = await game.loadSprite(ImageAssets.movingPlatform);
    _sprite = SpriteComponent(size: size, sprite: sprite);
    add(_sprite);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final previousX = position.x;
    _elapsed += dt;
    final offset = math.sin(_elapsed * speed) * travelDistance;
    position.x = startPosition.x + offset;
    delta
      ..x = position.x - previousX
      ..y = 0;
  }
}
