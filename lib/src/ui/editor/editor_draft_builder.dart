import 'package:flame/components.dart';

import '../../core/constants.dart';
import '../../world/level_models.dart';
import '../../world/platform_surface.dart';
import 'editor_constants.dart';
import 'editor_session_data.dart';

EditorSessionData restoreEditorSession(LevelData? savedDraft) {
  if (savedDraft == null) {
    return EditorSessionData(
      surfaces: [],
      coins: [],
      hearts: [],
      stars: [],
      spikes: [],
      saws: [],
      checkpoints: [],
      springs: [],
      walls: [],
      disappearingPlatforms: [],
    );
  }

  final editableSurfaces = savedDraft.surfaces.where((surface) {
    final isFloorSurface =
        surface.position.x == 0 &&
        surface.position.y ==
            EditorConstants.worldHeight - GameConstants.floorHeight &&
        surface.size.x == EditorConstants.worldWidth &&
        surface.size.y == GameConstants.floorHeight;
    return !isFloorSurface;
  });

  return EditorSessionData(
    surfaces: editableSurfaces
        .map(
          (surface) => PlatformSurface(
            position: surface.position.clone(),
            size: surface.size.clone(),
          ),
        )
        .toList(),
    coins: savedDraft.coinSpawnPoints.map((coin) => coin.clone()).toList(),
    hearts: savedDraft.heartSpawnPoints.map((heart) => heart.clone()).toList(),
    stars: savedDraft.starSpawnPoints.map((star) => star.clone()).toList(),
    spikes: savedDraft.spikeSpawnPoints.map((spike) => spike.clone()).toList(),
    saws: savedDraft.sawSpawnPoints.map((saw) => saw.clone()).toList(),
    checkpoints: savedDraft.checkpoints
        .map(
          (checkpoint) => CheckpointData(
            position: checkpoint.position.clone(),
            size: checkpoint.size.clone(),
            respawnPosition: checkpoint.respawnPosition.clone(),
          ),
        )
        .toList(),
    springs: savedDraft.springSpawnPoints
        .map((spring) => spring.clone())
        .toList(),
    walls: savedDraft.walls
        .map(
          (wall) => WallData(
            position: wall.position.clone(),
            size: wall.size.clone(),
            variant: wall.variant,
          ),
        )
        .toList(),
    disappearingPlatforms: savedDraft.disappearingPlatforms
        .map(
          (platform) => DisappearingPlatformData(
            position: platform.position.clone(),
            size: platform.size.clone(),
            collapseDelay: platform.collapseDelay,
            respawnDelay: platform.respawnDelay,
          ),
        )
        .toList(),
  );
}

LevelData buildDraftLevelData({
  required List<PlatformSurface> surfaces,
  required List<Vector2> coins,
  required List<Vector2> hearts,
  required List<Vector2> stars,
  required List<Vector2> spikes,
  required List<Vector2> saws,
  required List<CheckpointData> checkpoints,
  required List<Vector2> springs,
  required List<WallData> walls,
  required List<DisappearingPlatformData> disappearingPlatforms,
}) {
  final floorSurface = PlatformSurface(
    position: Vector2(
      0,
      EditorConstants.worldHeight - GameConstants.floorHeight,
    ),
    size: Vector2(EditorConstants.worldWidth, GameConstants.floorHeight),
  );
  final playerSpawn = Vector2(
    PlayerConstants.spawn.x.clamp(
      0,
      EditorConstants.worldWidth - PlayerConstants.size.x,
    ),
    EditorConstants.worldHeight -
        GameConstants.floorHeight -
        PlayerConstants.size.y,
  );
  final exitPosition = Vector2(
    EditorConstants.worldWidth - 160,
    EditorConstants.worldHeight - GameConstants.floorHeight - 64,
  );

  return LevelData(
    playerSpawn: playerSpawn,
    exitPosition: exitPosition,
    surfaces: [
      floorSurface,
      ...surfaces.map(
        (surface) => PlatformSurface(
          position: surface.position.clone(),
          size: surface.size.clone(),
        ),
      ),
    ],
    coinSpawnPoints: coins.map((coin) => coin.clone()).toList(),
    heartSpawnPoints: hearts.map((heart) => heart.clone()).toList(),
    starSpawnPoints: stars.map((star) => star.clone()).toList(),
    spikeSpawnPoints: spikes.map((spike) => spike.clone()).toList(),
    sawSpawnPoints: saws.map((saw) => saw.clone()).toList(),
    checkpoints: checkpoints
        .map(
          (checkpoint) => CheckpointData(
            position: checkpoint.position.clone(),
            size: checkpoint.size.clone(),
            respawnPosition: checkpoint.respawnPosition.clone(),
          ),
        )
        .toList(),
    springSpawnPoints: springs.map((spring) => spring.clone()).toList(),
    walls: walls
        .map(
          (wall) => WallData(
            position: wall.position.clone(),
            size: wall.size.clone(),
            variant: wall.variant,
          ),
        )
        .toList(),
    movingPlatforms: const [],
    verticalMovingPlatforms: const [],
    disappearingPlatforms: disappearingPlatforms
        .map(
          (platform) => DisappearingPlatformData(
            position: platform.position.clone(),
            size: platform.size.clone(),
            collapseDelay: platform.collapseDelay,
            respawnDelay: platform.respawnDelay,
          ),
        )
        .toList(),
    testPortals: const [],
  );
}
