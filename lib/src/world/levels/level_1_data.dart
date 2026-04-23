import 'package:flame/components.dart';

import '../level_models.dart';
import '../platform_surface.dart';

final LevelData level1Data = LevelData(
  playerSpawn: Vector2(160, 520),
  exitPosition: Vector2(2120, 560),
  surfaces: [
    PlatformSurface(position: Vector2(0, 624), size: Vector2(2240, 96)),
    PlatformSurface(position: Vector2(120, 540), size: Vector2(220, 28)),
    PlatformSurface(position: Vector2(420, 455), size: Vector2(210, 28)),
    PlatformSurface(position: Vector2(760, 365), size: Vector2(180, 28)),
    PlatformSurface(position: Vector2(1080, 500), size: Vector2(170, 28)),
    PlatformSurface(position: Vector2(980, 250), size: Vector2(210, 28)),
    PlatformSurface(position: Vector2(1625, 330), size: Vector2(200, 28)),
    PlatformSurface(position: Vector2(1885, 250), size: Vector2(170, 28)),
  ],
  coinSpawnPoints: [
    Vector2(195, 490),
    Vector2(500, 405),
    Vector2(825, 315),
    Vector2(1140, 450),
    Vector2(1060, 200),
    Vector2(1425, 370),
    Vector2(1700, 280),
    Vector2(1935, 200),
  ],
  heartSpawnPoints: [
    Vector2(1440, 386),
  ],
  starSpawnPoints: [
    Vector2(1865, 200),
  ],
  spikeSpawnPoints: [
    Vector2(620, 594),
    Vector2(1280, 594),
    Vector2(1540, 390),
  ],
  sawSpawnPoints: [
    Vector2(1098, 468),
    Vector2(1910, 218),
  ],
  checkpoints: [
    CheckpointData(
      position: Vector2(900, 301),
      size: Vector2(24, 64),
      respawnPosition: Vector2(840, 317),
    ),
    CheckpointData(
      position: Vector2(1760, 266),
      size: Vector2(24, 64),
      respawnPosition: Vector2(1700, 282),
    ),
  ],
  springSpawnPoints: [
    Vector2(700, 333),
    Vector2(1490, 388),
  ],
  walls: [
    WallData(
      position: Vector2(1508, 496),
      size: Vector2(32, 128),
    ),
  ],
  movingPlatforms: [
    MovingPlatformData(
      position: Vector2(560, 285),
      size: Vector2(96, 24),
      startPosition: Vector2(560, 285),
      travelDistance: 90,
      speed: 1.8,
    ),
    MovingPlatformData(
      position: Vector2(1180, 160),
      size: Vector2(96, 24),
      startPosition: Vector2(1180, 160),
      travelDistance: 110,
      speed: 1.4,
    ),
  ],
  verticalMovingPlatforms: const [],
  disappearingPlatforms: [
    DisappearingPlatformData(
      position: Vector2(1398, 420),
      size: Vector2(96, 28),
      collapseDelay: 0.5,
      respawnDelay: 2.0,
    ),
  ],
);
