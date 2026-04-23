import 'package:flame/components.dart';

import '../level_models.dart';
import '../platform_surface.dart';

final LevelData level3Data = LevelData(
  playerSpawn: Vector2(160, 576),
  exitPosition: Vector2(2080, 560),
  surfaces: [
    PlatformSurface(position: Vector2(0, 624), size: Vector2(2240, 96)),
    PlatformSurface(position: Vector2(768, 512), size: Vector2(128, 28)),
    PlatformSurface(position: Vector2(608, 416), size: Vector2(128, 28)),
    PlatformSurface(position: Vector2(768, 320), size: Vector2(128, 28)),
    PlatformSurface(position: Vector2(608, 224), size: Vector2(128, 28)),
    PlatformSurface(position: Vector2(768, 128), size: Vector2(128, 28)),
    PlatformSurface(position: Vector2(1504, 448), size: Vector2(128, 28)),
  ],
  coinSpawnPoints: [
    Vector2(108, 456),
    Vector2(228, 512),
    Vector2(356, 452),
    Vector2(484, 512),
    Vector2(796, 424),
    Vector2(844, 424),
    Vector2(640, 332),
    Vector2(688, 332),
    Vector2(948, 236),
    Vector2(496, 164),
    Vector2(1144, 124),
    Vector2(1144, 208),
    Vector2(1144, 292),
    Vector2(1144, 372),
    Vector2(1144, 464),
  ],
  spikeSpawnPoints: [
    Vector2(104, 592),
    Vector2(356, 592),
    Vector2(604, 592),
  ],
  sawSpawnPoints: [
    Vector2(1136, 580),
    Vector2(1244, 460),
    Vector2(1348, 456),
    Vector2(1440, 452),
    Vector2(1668, 452),
    Vector2(1756, 448),
  ],
  checkpoints: [],
  springSpawnPoints: [],
  movingPlatforms: [],
  disappearingPlatforms: [
    DisappearingPlatformData(
      position: Vector2(1504, 448),
      size: Vector2(128, 24),
      collapseDelay: 0.5,
      respawnDelay: 2.0,
    ),
  ],
);
