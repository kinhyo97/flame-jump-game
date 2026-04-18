// 밟으면 플레이어를 강하게 튀어오르게 하는 스프링 오브젝트 파일.
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/interactable.dart';

class Spring extends Interactable with HasGameReference<JumpGame> {
  Spring({required super.position, required super.size});

  bool isActive = false;
  Sprite? _idleSprite;
  Sprite? _activeSprite;
  SpriteComponent? _sprite;
  TimerComponent? _resetTimer;

  @override
  Future<void> onLoad() async {
    _idleSprite = await game.loadSprite(ImageAssets.springIdle);
    _activeSprite = await game.loadSprite(ImageAssets.springActive);

    _sprite = SpriteComponent(size: size, sprite: _idleSprite);
    add(_sprite!);
  }

  void trigger() {
    if (isActive) {
      return;
    }

    isActive = true;
    _sprite?.sprite = _activeSprite;
    _resetTimer?.removeFromParent();
    _resetTimer = TimerComponent(
      period: 0.2,
      removeOnFinish: true,
      onTick: () {
        isActive = false;
        _sprite?.sprite = _idleSprite;
      },
    );
    add(_resetTimer!);
  }

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
