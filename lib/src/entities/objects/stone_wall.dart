import 'package:flame/components.dart';

import '../../core/assets.dart';
import '../../game/jump_game.dart';
import '../../world/level_models.dart';
import '../base/game_entity.dart';

class StoneWall extends GameEntity with HasGameReference<JumpGame> {
  static const double _tileSize = 32;
  static const double _horizontalCollisionInset = 6;

  StoneWall({
    required super.position,
    required super.size,
    this.variant = WallSegmentVariant.auto,
  });

  final WallSegmentVariant variant;

  double get left => position.x + _horizontalCollisionInset;
  double get right => position.x + size.x - _horizontalCollisionInset;
  double get top => position.y;
  double get bottom => position.y + size.y;

  @override
  Future<void> onLoad() async {
    final topSprite = await game.loadSprite(ImageAssets.terrainStoneVerticalTop);
    final middleSprite = await game.loadSprite(ImageAssets.terrainStoneVerticalMiddle);
    final bottomSprite =
        await game.loadSprite(ImageAssets.terrainStoneVerticalBottom);

    if (variant != WallSegmentVariant.auto) {
      final sprite = switch (variant) {
        WallSegmentVariant.top => topSprite,
        WallSegmentVariant.middle => middleSprite,
        WallSegmentVariant.bottom => bottomSprite,
        WallSegmentVariant.auto => topSprite,
      };

      add(
        SpriteComponent(
          sprite: sprite,
          size: size,
        ),
      );
      return;
    }

    final columns = (size.x / _tileSize).ceil().clamp(1, 999);
    final rows = (size.y / _tileSize).ceil().clamp(2, 999);

    for (var column = 0; column < columns; column++) {
      for (var row = 0; row < rows; row++) {
        final sprite = switch (row) {
          0 => topSprite,
          _ when row == rows - 1 => bottomSprite,
          _ => middleSprite,
        };

        add(
          SpriteComponent(
            sprite: sprite,
            position: Vector2(column * _tileSize, row * _tileSize),
            size: Vector2(_tileSize, _tileSize),
          ),
        );
      }
    }
  }
}
