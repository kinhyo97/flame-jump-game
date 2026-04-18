// 바닥형 용암 위험 요소를 표현하기 위한 hazard 엔티티 파일.
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/hazard.dart';

class Lava extends Hazard with HasGameReference<JumpGame> {
  Lava({required super.position, required super.size});

  static const double _tileWidth = 32;
  static const double _topHeight = 16;

  @override
  Future<void> onLoad() async {
    final baseSprite = await game.loadSprite(ImageAssets.lava);
    final topAnimation = SpriteAnimation.spriteList([
      await game.loadSprite(ImageAssets.lavaTop),
      await game.loadSprite(ImageAssets.lavaTopLow),
      await game.loadSprite(ImageAssets.lavaTop),
      await game.loadSprite(ImageAssets.lavaTopLow),
    ], stepTime: 0.2);

    final columns = (size.x / _tileWidth).ceil();

    for (var column = 0; column < columns; column++) {
      final x = column * _tileWidth;
      final tileWidth = (size.x - x).clamp(0.0, _tileWidth).toDouble();
      if (tileWidth <= 0) {
        continue;
      }

      add(
        SpriteComponent(
          position: Vector2(x, 0),
          size: Vector2(tileWidth, size.y),
          sprite: baseSprite,
        ),
      );
      add(
        SpriteAnimationComponent(
          position: Vector2(x, -4),
          size: Vector2(tileWidth, _topHeight),
          animation: topAnimation,
        ),
      );
    }
  }

  @override
  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
