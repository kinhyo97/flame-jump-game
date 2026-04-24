// 플레이어가 획득할 수 있는 코인을 표시하고 상태를 보관하는 아이템 파일.
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/collectible.dart';

class Coin extends Collectible with HasGameReference<JumpGame> {
  Coin({required super.position, required super.size});

  bool collected = false;

  @override
  Future<void> onLoad() async {
    final animation = SpriteAnimation.spriteList([
      await game.loadSprite(ImageAssets.coinGold),
      await game.loadSprite(ImageAssets.coinGoldSide),
      await game.loadSprite(ImageAssets.coinGold),
      await game.loadSprite(ImageAssets.coinGoldSide),
    ], stepTime: 0.12);

    add(
      SpriteAnimationComponent(
        position: size / 2,
        size: size,
        anchor: Anchor.center,
        animation: animation,
      ),
    );
  }

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
