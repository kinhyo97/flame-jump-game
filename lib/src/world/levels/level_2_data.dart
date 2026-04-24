import 'package:flame/components.dart';

import '../level_models.dart';
import '../platform_surface.dart';

final LevelData level2Data = LevelData(
  worldWidth: 2240,
  playerSpawn: Vector2(160, 576),
  exitPosition: Vector2(2080, 560),
  surfaces: [
    PlatformSurface(position: Vector2(0, 624), size: Vector2(2240, 96)),
    PlatformSurface(position: Vector2(160, 548), size: Vector2(150, 28)),
    PlatformSurface(position: Vector2(390, 485), size: Vector2(160, 28)),
    PlatformSurface(position: Vector2(640, 420), size: Vector2(180, 28)),
  ],
  coinSpawnPoints: [
    Vector2(200, 498),
    Vector2(455, 435),
    Vector2(710, 370),
    Vector2(1052, 168),
    Vector2(1144, 168),
    Vector2(1328, 168),
    Vector2(1416, 168),
    Vector2(2164, 388),
  ],
  heartSpawnPoints: [],
  starSpawnPoints: [],
  spikeSpawnPoints: [],
  sawSpawnPoints: [
    Vector2(324, 436),
    Vector2(568, 384),
    Vector2(844, 332),
  ],
  checkpoints: [],
  springSpawnPoints: [],
  walls: [
    WallData(
      position: Vector2(960, 272),
      size: Vector2(32, 32),
      variant: WallSegmentVariant.top,
    ),
    WallData(
      position: Vector2(1248, 272),
      size: Vector2(32, 32),
      variant: WallSegmentVariant.top,
    ),
    WallData(
      position: Vector2(1504, 272),
      size: Vector2(32, 32),
      variant: WallSegmentVariant.top,
    ),
  ],
  movingPlatforms: [],
  verticalMovingPlatforms: [],
  disappearingPlatforms: [
    DisappearingPlatformData(
      position: Vector2(1664, 272),
      size: Vector2(96, 28),
      collapseDelay: 0.5,
      respawnDelay: 2,
    ),
    DisappearingPlatformData(
      position: Vector2(1856, 272),
      size: Vector2(96, 28),
      collapseDelay: 0.5,
      respawnDelay: 2,
    ),
  ],
  testPortals: [],
);
