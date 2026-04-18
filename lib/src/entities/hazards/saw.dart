// 회전하는 톱날 위험 요소를 표현하는 hazard 엔티티 파일.
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/hazard.dart';

class Saw extends Hazard with HasGameReference<JumpGame> {
  Saw({required super.position, required super.size});

  late final SpriteComponent _sprite;

  @override
  Future<void> onLoad() async {
    final sprite = await game.loadSprite(ImageAssets.saw);

    _sprite = SpriteComponent(
      size: size,
      sprite: sprite,
      anchor: Anchor.center,
      position: size / 2,
    );

    add(_sprite);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _sprite.angle += dt * 3.6;
  }

  @override
  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
