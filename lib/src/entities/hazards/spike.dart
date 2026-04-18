// 고정형 가시 장애물을 표현하는 hazard 엔티티 파일.
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/hazard.dart';

class Spike extends Hazard with HasGameReference<JumpGame> {
  Spike({required super.position, required super.size});

  @override
  Future<void> onLoad() async {
    final sprite = await game.loadSprite(ImageAssets.spikes);

    add(SpriteComponent(size: size, sprite: sprite));
  }

  @override
  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
