import 'package:flame/components.dart';

import 'platform_surface.dart';

class MovingPlatformData {
  const MovingPlatformData({
    required this.position,
    required this.size,
    required this.startPosition,
    required this.travelDistance,
    required this.speed,
  });

  final Vector2 position;
  final Vector2 size;
  final Vector2 startPosition;
  final double travelDistance;
  final double speed;
}

class DisappearingPlatformData {
  const DisappearingPlatformData({
    required this.position,
    required this.size,
    this.collapseDelay = 0.5,
    this.respawnDelay = 2.0,
  });

  final Vector2 position;
  final Vector2 size;
  final double collapseDelay;
  final double respawnDelay;
}

class VerticalMovingPlatformData {
  const VerticalMovingPlatformData({
    required this.position,
    required this.size,
    required this.startPosition,
    required this.travelDistance,
    required this.speed,
    this.startsMovingUp = true,
  });

  final Vector2 position;
  final Vector2 size;
  final Vector2 startPosition;
  final double travelDistance;
  final double speed;
  final bool startsMovingUp;
}

class CheckpointData {
  const CheckpointData({
    required this.position,
    required this.size,
    required this.respawnPosition,
  });

  final Vector2 position;
  final Vector2 size;
  final Vector2 respawnPosition;
}

enum WallSegmentVariant {
  auto,
  top,
  middle,
  bottom,
}

class WallData {
  const WallData({
    required this.position,
    required this.size,
    this.variant = WallSegmentVariant.auto,
  });

  final Vector2 position;
  final Vector2 size;
  final WallSegmentVariant variant;
}

class TestPortalData {
  const TestPortalData({
    required this.position,
    required this.size,
    required this.targetStageIndex,
  });

  final Vector2 position;
  final Vector2 size;
  final int targetStageIndex;
}

class LevelData {
  const LevelData({
    required this.playerSpawn,
    required this.exitPosition,
    required this.surfaces,
    required this.coinSpawnPoints,
    this.heartSpawnPoints = const [],
    this.starSpawnPoints = const [],
    required this.spikeSpawnPoints,
    required this.sawSpawnPoints,
    required this.checkpoints,
    required this.springSpawnPoints,
    this.walls = const [],
    required this.movingPlatforms,
    this.verticalMovingPlatforms = const [],
    this.disappearingPlatforms = const [],
    this.testPortals = const [],
  });

  final Vector2 playerSpawn;
  final Vector2 exitPosition;
  final List<PlatformSurface> surfaces;
  final List<Vector2> coinSpawnPoints;
  final List<Vector2> heartSpawnPoints;
  final List<Vector2> starSpawnPoints;
  final List<Vector2> spikeSpawnPoints;
  final List<Vector2> sawSpawnPoints;
  final List<CheckpointData> checkpoints;
  final List<Vector2> springSpawnPoints;
  final List<WallData> walls;
  final List<MovingPlatformData> movingPlatforms;
  final List<VerticalMovingPlatformData> verticalMovingPlatforms;
  final List<DisappearingPlatformData> disappearingPlatforms;
  final List<TestPortalData> testPortals;
}
