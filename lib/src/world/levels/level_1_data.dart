import 'package:flame/components.dart';

import '../level_models.dart';
import '../platform_surface.dart';

final LevelData level1Data = LevelData(
  playerSpawn: Vector2(160, 520),
  exitPosition: Vector2(2100, 560),
  surfaces: [
    PlatformSurface(position: Vector2(0, 624), size: Vector2(2240, 96)),
    PlatformSurface(position: Vector2(140, 540), size: Vector2(220, 28)),
    PlatformSurface(position: Vector2(460, 500), size: Vector2(180, 28)),
    PlatformSurface(position: Vector2(740, 455), size: Vector2(170, 28)),
    PlatformSurface(position: Vector2(1010, 410), size: Vector2(180, 28)),
    PlatformSurface(position: Vector2(1320, 520), size: Vector2(180, 28)),
    PlatformSurface(position: Vector2(1700, 420), size: Vector2(180, 28)),
  ],
  coinSpawnPoints: [
    Vector2(200, 490),
    Vector2(540, 450),
    Vector2(820, 405),
    Vector2(1095, 360),
    Vector2(1385, 470),
    Vector2(1590, 390),
    Vector2(1765, 370),
    Vector2(2030, 570),
  ],
  heartSpawnPoints: [
    Vector2(1460, 488),
  ],
  starSpawnPoints: const [],
  spikeSpawnPoints: [
    Vector2(660, 594),
    Vector2(1540, 594),
  ],
  sawSpawnPoints: const [],
  checkpoints: [
    CheckpointData(
      position: Vector2(1220, 346),
      size: Vector2(24, 64),
      respawnPosition: Vector2(1060, 362),
    ),
  ],
  springSpawnPoints: [
    Vector2(1640, 388),
  ],
  walls: const [],
  movingPlatforms: const [],
  verticalMovingPlatforms: [
    VerticalMovingPlatformData(
      position: Vector2(1540, 500),
      size: Vector2(96, 24),
      startPosition: Vector2(1540, 500),
      travelDistance: 110,
      speed: 1.15,
      startsMovingUp: true,
    ),
  ],
  disappearingPlatforms: const [],
);
