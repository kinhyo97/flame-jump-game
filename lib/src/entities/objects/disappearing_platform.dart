import 'dart:math' as math;

import 'package:flame/components.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../base/game_entity.dart';

class DisappearingPlatform extends GameEntity with HasGameReference<JumpGame> {
  DisappearingPlatform({
    required super.position,
    required super.size,
    required this.collapseDelay,
    required this.respawnDelay,
  });

  final double collapseDelay;
  final double respawnDelay;

  late final Vector2 _basePosition;
  late final SpriteComponent _sprite;

  bool _isSolid = true;
  bool _isTriggered = false;
  bool _isHidden = false;
  double _collapseTimer = 0;
  double _respawnTimer = 0;

  bool get isSolid => _isSolid;
  double get left => position.x;
  double get right => position.x + size.x;
  double get top => position.y;
  double get bottom => position.y + size.y;

  @override
  Future<void> onLoad() async {
    _basePosition = position.clone();
    _sprite = SpriteComponent(
      size: size,
      sprite: await game.loadSprite(ImageAssets.movingPlatform),
    );
    add(_sprite);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isHidden) {
      _respawnTimer += dt;
      if (_respawnTimer >= respawnDelay) {
        _restore();
      }
      return;
    }

    if (!_isTriggered) {
      return;
    }

    _collapseTimer += dt;
    final shake = math.sin(_collapseTimer * 40) * 1.5;
    position.x = _basePosition.x + shake;
    _sprite.opacity = _collapseTimer % 0.12 < 0.06 ? 0.35 : 1;

    if (_collapseTimer >= collapseDelay) {
      _hide();
    }
  }

  void onPlayerLanded() {
    if (_isTriggered || _isHidden) {
      return;
    }

    _isTriggered = true;
    _collapseTimer = 0;
  }

  void _hide() {
    _isTriggered = false;
    _isHidden = true;
    _isSolid = false;
    _respawnTimer = 0;
    position = _basePosition.clone();
    _sprite.opacity = 0;
  }

  void _restore() {
    _isHidden = false;
    _isSolid = true;
    _isTriggered = false;
    _collapseTimer = 0;
    _respawnTimer = 0;
    position = _basePosition.clone();
    _sprite.opacity = 1;
  }
}
