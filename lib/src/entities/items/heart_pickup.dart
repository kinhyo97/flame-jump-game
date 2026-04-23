import 'dart:math' as math;

import 'package:flame/components.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/collectible.dart';

class HeartPickup extends Collectible with HasGameReference<JumpGame> {
  HeartPickup({required super.position, required super.size});

  bool collected = false;
  late final Vector2 _basePosition;
  SpriteComponent? _sprite;
  double _elapsed = 0;

  @override
  Future<void> onLoad() async {
    _basePosition = position.clone();
    _sprite = SpriteComponent(
      position: size / 2,
      size: size,
      anchor: Anchor.center,
      sprite: await game.loadSprite(ImageAssets.heartPickup),
    );
    add(_sprite!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position.y = _basePosition.y + math.sin(_elapsed * 2.8) * 3;
  }
}
