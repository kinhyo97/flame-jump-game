// 코인 수집 완료 후 열리는 출구 문 오브젝트를 정의하는 파일.
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/interactable.dart';

class ExitGate extends Interactable with HasGameReference<JumpGame> {
  ExitGate({required super.position, required super.size});

  bool isOpen = false;

  Sprite? _closedSprite;
  Sprite? _openSprite;
  SpriteComponent? _sprite;

  @override
  Future<void> onLoad() async {
    _closedSprite = await game.loadSprite(ImageAssets.doorClosed);
    _openSprite = await game.loadSprite(ImageAssets.doorOpen);

    _sprite = SpriteComponent(size: size, sprite: _closedSprite);

    add(_sprite!);
  }

  void openGate() {
    isOpen = true;
    _sprite?.sprite = _openSprite;
  }

  void resetGate() {
    isOpen = false;
    _sprite?.sprite = _closedSprite;
  }

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
