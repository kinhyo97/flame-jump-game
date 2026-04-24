import 'level_models.dart';
import 'platform_surface.dart';

final class EditorDraftStore {
  EditorDraftStore._();

  static LevelData? _currentLevel;

  static LevelData? get currentLevel {
    final level = _currentLevel;
    if (level == null) {
      return null;
    }

    return clone(level);
  }

  static void save(LevelData level) {
    _currentLevel = clone(level);
  }

  static LevelData clone(LevelData level) {
    return LevelData(
      worldWidth: level.worldWidth,
      playerSpawn: level.playerSpawn.clone(),
      exitPosition: level.exitPosition.clone(),
      surfaces: level.surfaces
          .map(
            (surface) => PlatformSurface(
              position: surface.position.clone(),
              size: surface.size.clone(),
            ),
          )
          .toList(),
      coinSpawnPoints: level.coinSpawnPoints.map((coin) => coin.clone()).toList(),
      heartSpawnPoints: level.heartSpawnPoints
          .map((heart) => heart.clone())
          .toList(),
      starSpawnPoints: level.starSpawnPoints
          .map((star) => star.clone())
          .toList(),
      spikeSpawnPoints: level.spikeSpawnPoints
          .map((spike) => spike.clone())
          .toList(),
      sawSpawnPoints: level.sawSpawnPoints.map((saw) => saw.clone()).toList(),
      checkpoints: level.checkpoints
          .map(
            (checkpoint) => CheckpointData(
              position: checkpoint.position.clone(),
              size: checkpoint.size.clone(),
              respawnPosition: checkpoint.respawnPosition.clone(),
            ),
          )
          .toList(),
      springSpawnPoints: level.springSpawnPoints
          .map((spring) => spring.clone())
          .toList(),
      walls: level.walls
          .map(
            (wall) => WallData(
              position: wall.position.clone(),
              size: wall.size.clone(),
              variant: wall.variant,
            ),
          )
          .toList(),
      movingPlatforms: level.movingPlatforms
          .map(
            (platform) => MovingPlatformData(
              position: platform.position.clone(),
              size: platform.size.clone(),
              startPosition: platform.startPosition.clone(),
              travelDistance: platform.travelDistance,
              speed: platform.speed,
            ),
          )
          .toList(),
      verticalMovingPlatforms: level.verticalMovingPlatforms
          .map(
            (platform) => VerticalMovingPlatformData(
              position: platform.position.clone(),
              size: platform.size.clone(),
              startPosition: platform.startPosition.clone(),
              travelDistance: platform.travelDistance,
              speed: platform.speed,
              startsMovingUp: platform.startsMovingUp,
            ),
          )
          .toList(),
      disappearingPlatforms: level.disappearingPlatforms
          .map(
            (platform) => DisappearingPlatformData(
              position: platform.position.clone(),
              size: platform.size.clone(),
              collapseDelay: platform.collapseDelay,
              respawnDelay: platform.respawnDelay,
            ),
          )
          .toList(),
      testPortals: level.testPortals
          .map(
            (portal) => TestPortalData(
              position: portal.position.clone(),
              size: portal.size.clone(),
              targetStageIndex: portal.targetStageIndex,
            ),
          )
          .toList(),
    );
  }
}
