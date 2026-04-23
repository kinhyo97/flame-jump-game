import 'package:flame/components.dart';

import '../level_models.dart';
import '../platform_surface.dart';

final LevelData mapTestHubLevel = LevelData(
  playerSpawn: Vector2(140, 520),
  exitPosition: Vector2(-200, -200),
  surfaces: [
    PlatformSurface(position: Vector2(0, 624), size: Vector2(2240, 96)),
    PlatformSurface(position: Vector2(250, 545), size: Vector2(120, 28)),
    PlatformSurface(position: Vector2(440, 545), size: Vector2(120, 28)),
    PlatformSurface(position: Vector2(630, 545), size: Vector2(120, 28)),
    PlatformSurface(position: Vector2(820, 545), size: Vector2(120, 28)),
    PlatformSurface(position: Vector2(1010, 545), size: Vector2(120, 28)),
    PlatformSurface(position: Vector2(1200, 545), size: Vector2(120, 28)),
  ],
  coinSpawnPoints: [],
  spikeSpawnPoints: [],
  sawSpawnPoints: [],
  checkpoints: const [],
  springSpawnPoints: const [],
  movingPlatforms: const [],
  testPortals: [
    TestPortalData(
      position: Vector2(286, 481),
      size: Vector2(48, 64),
      targetStageIndex: 0,
    ),
    TestPortalData(
      position: Vector2(476, 481),
      size: Vector2(48, 64),
      targetStageIndex: 1,
    ),
    TestPortalData(
      position: Vector2(666, 481),
      size: Vector2(48, 64),
      targetStageIndex: 2,
    ),
    TestPortalData(
      position: Vector2(856, 481),
      size: Vector2(48, 64),
      targetStageIndex: 3,
    ),
    TestPortalData(
      position: Vector2(1046, 481),
      size: Vector2(48, 64),
      targetStageIndex: 4,
    ),
    TestPortalData(
      position: Vector2(1236, 481),
      size: Vector2(48, 64),
      targetStageIndex: 5,
    ),
  ],
);
