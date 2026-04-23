import 'package:flame/components.dart';

import '../level_models.dart';
import '../platform_surface.dart';

final LevelData level4Data = LevelData(
  playerSpawn: Vector2(120, 520),
  exitPosition: Vector2(2070, 108),
  surfaces: [
    PlatformSurface(position: Vector2(0, 624), size: Vector2(2240, 96)),
    PlatformSurface(position: Vector2(150, 545), size: Vector2(110, 28)),
    PlatformSurface(position: Vector2(345, 470), size: Vector2(120, 28)),
    PlatformSurface(position: Vector2(560, 405), size: Vector2(120, 28)),
    PlatformSurface(position: Vector2(805, 338), size: Vector2(120, 28)),
    PlatformSurface(position: Vector2(1030, 270), size: Vector2(135, 28)),
    PlatformSurface(position: Vector2(1305, 210), size: Vector2(125, 28)),
    PlatformSurface(position: Vector2(1575, 162), size: Vector2(120, 28)),
    PlatformSurface(position: Vector2(1855, 118), size: Vector2(165, 28)),
    PlatformSurface(position: Vector2(1490, 455), size: Vector2(120, 28)),
    PlatformSurface(position: Vector2(1760, 310), size: Vector2(105, 28)),
  ],
  coinSpawnPoints: [
    Vector2(185, 495),
    Vector2(390, 420),
    Vector2(610, 355),
    Vector2(855, 288),
    Vector2(1088, 220),
    Vector2(1365, 160),
    Vector2(1630, 112),
    Vector2(1915, 68),
    Vector2(1535, 405),
    Vector2(1750, 238),
    Vector2(2140, 572),
  ],
  spikeSpawnPoints: [
    Vector2(280, 594),
    Vector2(500, 594),
    Vector2(720, 594),
    Vector2(945, 594),
    Vector2(1180, 594),
    Vector2(1435, 594),
    Vector2(1675, 132),
    Vector2(1888, 88),
  ],
  sawSpawnPoints: [
    Vector2(442, 438),
    Vector2(900, 306),
    Vector2(1460, 178),
    Vector2(1805, 278),
  ],
  checkpoints: [
    CheckpointData(
      position: Vector2(780, 274),
      size: Vector2(24, 64),
      respawnPosition: Vector2(735, 290),
    ),
    CheckpointData(
      position: Vector2(1470, 391),
      size: Vector2(24, 64),
      respawnPosition: Vector2(1430, 407),
    ),
    CheckpointData(
      position: Vector2(1825, 246),
      size: Vector2(24, 64),
      respawnPosition: Vector2(1755, 262),
    ),
  ],
  springSpawnPoints: [
    Vector2(470, 592),
    Vector2(980, 592),
    Vector2(1425, 592),
    Vector2(1710, 278),
  ],
  movingPlatforms: [
    MovingPlatformData(
      position: Vector2(260, 350),
      size: Vector2(96, 24),
      startPosition: Vector2(260, 350),
      travelDistance: 130,
      speed: 1.9,
    ),
    MovingPlatformData(
      position: Vector2(700, 225),
      size: Vector2(96, 24),
      startPosition: Vector2(700, 225),
      travelDistance: 145,
      speed: 2.1,
    ),
    MovingPlatformData(
      position: Vector2(1185, 370),
      size: Vector2(96, 24),
      startPosition: Vector2(1185, 370),
      travelDistance: 140,
      speed: 1.8,
    ),
    MovingPlatformData(
      position: Vector2(1650, 92),
      size: Vector2(96, 24),
      startPosition: Vector2(1650, 92),
      travelDistance: 120,
      speed: 2.2,
    ),
  ],
);
