import 'package:flame/components.dart';

import '../level_models.dart';
import '../platform_surface.dart';

final LevelData level2Data = LevelData(
  playerSpawn: Vector2(160, 576),
  exitPosition: Vector2(2080, 560),
  surfaces: [
    PlatformSurface(position: Vector2(0, 624), size: Vector2(2240, 96)),
    PlatformSurface(position: Vector2(160, 548), size: Vector2(150, 28)),
    PlatformSurface(position: Vector2(390, 485), size: Vector2(160, 28)),
    PlatformSurface(position: Vector2(640, 420), size: Vector2(180, 28)),
    PlatformSurface(position: Vector2(930, 350), size: Vector2(170, 28)),
    PlatformSurface(position: Vector2(1220, 290), size: Vector2(200, 28)),
    PlatformSurface(position: Vector2(1550, 235), size: Vector2(170, 28)),
    PlatformSurface(position: Vector2(1850, 185), size: Vector2(190, 28)),
  ],
  coinSpawnPoints: [
    Vector2(200, 498),
    Vector2(455, 435),
    Vector2(710, 370),
    Vector2(1000, 300),
    Vector2(1285, 240),
    Vector2(1615, 185),
    Vector2(1920, 135),
  ],
  spikeSpawnPoints: [
    Vector2(560, 594),
    Vector2(840, 594),
    Vector2(1120, 594),
    Vector2(1710, 205),
  ],
  sawSpawnPoints: [
    Vector2(744, 388),
    Vector2(1325, 258),
    Vector2(1985, 153),
    Vector2(1136, 180),
    Vector2(1460, 128),
    Vector2(1604, 92),
  ],
  checkpoints: [
    CheckpointData(
      position: Vector2(880, 286),
      size: Vector2(24, 64),
      respawnPosition: Vector2(820, 302),
    ),
  ],
  springSpawnPoints: [
    Vector2(570, 388),
    Vector2(1765, 153),
  ],
  movingPlatforms: [],
  verticalMovingPlatforms: [
    VerticalMovingPlatformData(
      position: Vector2(520, 500),
      size: Vector2(96, 24),
      startPosition: Vector2(520, 500),
      travelDistance: 92,
      speed: 1.3,
      startsMovingUp: true,
    ),
    VerticalMovingPlatformData(
      position: Vector2(1460, 250),
      size: Vector2(96, 24),
      startPosition: Vector2(1460, 250),
      travelDistance: 86,
      speed: 1.15,
      startsMovingUp: false,
    ),
  ],
);
