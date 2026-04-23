import 'dart:math' as math;

import 'package:flame/components.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/game_entity.dart';

class VerticalMovingPlatform extends GameEntity with HasGameReference<JumpGame> {
  VerticalMovingPlatform({
    required super.position,
    required super.size,
    required this.startPosition,
    required this.travelDistance,
    required this.speed,
    required this.startsMovingUp,
  });

  final Vector2 startPosition;
  final double travelDistance;
  final double speed;
  final bool startsMovingUp;
  final Vector2 delta = Vector2.zero();

  double _elapsed = 0;
  late final SpriteComponent _sprite;

  double get left => position.x;
  double get right => position.x + size.x;
  double get top => position.y;
  double get bottom => position.y + size.y;

  @override
  Future<void> onLoad() async {
    final sprite = await game.loadSprite(ImageAssets.movingPlatform);
    _sprite = SpriteComponent(size: size, sprite: sprite);
    add(_sprite);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final previousY = position.y;
    _elapsed += dt;
    final direction = startsMovingUp ? -1.0 : 1.0;
    final offset = math.sin(_elapsed * speed) * travelDistance * direction;
    position.y = startPosition.y + offset;
    delta
      ..x = 0
      ..y = position.y - previousY;
  }
}
