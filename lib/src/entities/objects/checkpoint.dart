// 리스폰 위치를 갱신하는 체크포인트 오브젝트를 정의하는 파일.
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/interactable.dart';

class Checkpoint extends Interactable with HasGameReference<JumpGame> {
  Checkpoint({
    required super.position,
    required super.size,
    required this.respawnPosition,
  });

  final Vector2 respawnPosition;
  bool isActive = false;

  Sprite? _inactiveSprite;
  Sprite? _activeSprite;
  SpriteComponent? _sprite;

  @override
  Future<void> onLoad() async {
    _inactiveSprite = await game.loadSprite(ImageAssets.checkpointInactive);
    _activeSprite = await game.loadSprite(ImageAssets.checkpointActive);

    _sprite = SpriteComponent(size: size, sprite: _inactiveSprite);
    add(_sprite!);
  }

  void activate() {
    isActive = true;
    _sprite?.sprite = _activeSprite;
  }

  void deactivate() {
    isActive = false;
    _sprite?.sprite = _inactiveSprite;
  }

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
