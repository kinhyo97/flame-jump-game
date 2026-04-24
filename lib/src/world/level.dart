// 월드 바닥과 이후 발판/오브젝트 배치의 기준이 되는 기본 레벨 파일.
import 'package:flame/components.dart';

import '../core/assets.dart';
import '../core/constants.dart';
import '../entities/hazards/saw.dart';
import '../entities/hazards/spike.dart';
import '../entities/items/coin.dart';
import '../entities/items/heart_pickup.dart';
import '../entities/items/star_pickup.dart';
import '../entities/objects/checkpoint.dart';
import '../entities/objects/disappearing_platform.dart';
import '../entities/objects/exit_gate.dart';
import '../entities/objects/moving_platform.dart';
import '../entities/objects/stone_wall.dart';
import '../entities/objects/spring.dart';
import '../entities/objects/test_portal.dart';
import '../entities/objects/vertical_moving_platform.dart';
import '../game/jump_game.dart';
import 'levels_registry.dart';

class Level extends PositionComponent with HasGameReference<JumpGame> {
  Level()
    : coins = [],
      hearts = [],
      stars = [],
      spikes = [],
      saws = [],
      checkpoints = [],
      springs = [],
      walls = [],
      movingPlatforms = [],
      verticalMovingPlatforms = [],
      disappearingPlatforms = [],
      testPortals = [],
      surfaces = [];

  static const double _tileSize = 32;

  List<PlatformSurface> surfaces;
  final List<Coin> coins;
  final List<HeartPickup> hearts;
  final List<StarPickup> stars;
  final List<Spike> spikes;
  final List<Saw> saws;
  final List<Checkpoint> checkpoints;
  final List<Spring> springs;
  final List<StoneWall> walls;
  final List<MovingPlatform> movingPlatforms;
  final List<VerticalMovingPlatform> verticalMovingPlatforms;
  final List<DisappearingPlatform> disappearingPlatforms;
  final List<TestPortal> testPortals;
  final List<Component> _stageComponents = [];
  late final Sprite _backgroundSprite;
  late final Sprite _blockTopLeftSprite;
  late final Sprite _blockTopSprite;
  late final Sprite _blockTopRightSprite;
  late final Sprite _blockLeftSprite;
  late final Sprite _blockCenterSprite;
  late final Sprite _blockRightSprite;
  late final Sprite _blockBottomLeftSprite;
  late final Sprite _blockBottomSprite;
  late final Sprite _blockBottomRightSprite;
  late final Sprite _platformLeftSprite;
  late final Sprite _platformMiddleSprite;
  late final Sprite _platformRightSprite;
  late final SpriteComponent _background;
  late ExitGate exitGate;
  LevelData? _overrideStageData;
  int _currentStageIndex = 0;

  double get worldWidth => currentStage.worldWidth;
  double get worldHeight => GameConstants.levelHeight;
  int get totalStages => _overrideStageData != null ? 1 : gameLevels.length;
  int get currentStageNumber => _overrideStageData != null ? 1 : _currentStageIndex + 1;
  bool get hasNextStage => _overrideStageData == null && _currentStageIndex < totalStages - 1;
  bool get isHubStage => _overrideStageData != null;
  LevelData get currentStage => _overrideStageData ?? gameLevels[_currentStageIndex];

  @override
  Future<void> onLoad() async {
    await _loadTerrainSprites();
    _background = SpriteComponent(
      sprite: _backgroundSprite,
      position: Vector2.zero(),
      size: Vector2(worldWidth, worldHeight),
      priority: -100,
    );
    add(_background);
  }

  Future<void> _loadTerrainSprites() async {
    _backgroundSprite = await game.loadSprite(ImageAssets.backgroundSky);
    _blockTopLeftSprite = await game.loadSprite(ImageAssets.terrainGrassBlockTopLeft);
    _blockTopSprite = await game.loadSprite(ImageAssets.terrainGrassBlockTop);
    _blockTopRightSprite = await game.loadSprite(ImageAssets.terrainGrassBlockTopRight);
    _blockLeftSprite = await game.loadSprite(ImageAssets.terrainGrassBlockLeft);
    _blockCenterSprite = await game.loadSprite(ImageAssets.terrainGrassBlockCenter);
    _blockRightSprite = await game.loadSprite(ImageAssets.terrainGrassBlockRight);
    _blockBottomLeftSprite = await game.loadSprite(ImageAssets.terrainGrassBlockBottomLeft);
    _blockBottomSprite = await game.loadSprite(ImageAssets.terrainGrassBlockBottom);
    _blockBottomRightSprite = await game.loadSprite(ImageAssets.terrainGrassBlockBottomRight);
    _platformLeftSprite = await game.loadSprite(ImageAssets.terrainGrassHorizontalLeft);
    _platformMiddleSprite = await game.loadSprite(ImageAssets.terrainGrassHorizontalMiddle);
    _platformRightSprite = await game.loadSprite(ImageAssets.terrainGrassHorizontalRight);
  }

  void _buildTerrainVisuals() {
    for (var i = 0; i < surfaces.length; i++) {
      final surface = surfaces[i];
      if (i == 0) {
        _addGroundSurfaceVisual(surface);
      } else {
        _addFloatingSurfaceVisual(surface);
      }
    }

  }

  void _addGroundSurfaceVisual(PlatformSurface surface) {
    final columns = (surface.size.x / _tileSize).ceil();
    final rows = (surface.size.y / _tileSize).ceil();

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final isTop = row == 0;
        final isBottom = row == rows - 1;
        final isLeft = column == 0;
        final isRight = column == columns - 1;

        add(
          _trackStageComponent(
            SpriteComponent(
            sprite: _groundSpriteFor(isTop, isBottom, isLeft, isRight),
            position: Vector2(
              surface.position.x + column * _tileSize,
              surface.position.y + row * _tileSize,
            ),
            size: Vector2(_tileSize, _tileSize),
            priority: -20,
            ),
          ),
        );
      }
    }
  }

  void _addFloatingSurfaceVisual(PlatformSurface surface) {
    final columns = (surface.size.x / _tileSize).ceil().clamp(2, 999);
    final top = surface.position.y - 4;

    for (var column = 0; column < columns; column++) {
      final sprite = switch (column) {
        0 => _platformLeftSprite,
        _ when column == columns - 1 => _platformRightSprite,
        _ => _platformMiddleSprite,
      };

      add(
        _trackStageComponent(
          SpriteComponent(
          sprite: sprite,
          position: Vector2(surface.position.x + column * _tileSize, top),
          size: Vector2(_tileSize, _tileSize),
          priority: -20,
          ),
        ),
      );
    }
  }

  Sprite _groundSpriteFor(
    bool isTop,
    bool isBottom,
    bool isLeft,
    bool isRight,
  ) {
    if (isTop && isLeft) {
      return _blockTopLeftSprite;
    }
    if (isTop && isRight) {
      return _blockTopRightSprite;
    }
    if (isBottom && isLeft) {
      return _blockBottomLeftSprite;
    }
    if (isBottom && isRight) {
      return _blockBottomRightSprite;
    }
    if (isTop) {
      return _blockTopSprite;
    }
    if (isBottom) {
      return _blockBottomSprite;
    }
    if (isLeft) {
      return _blockLeftSprite;
    }
    if (isRight) {
      return _blockRightSprite;
    }
    return _blockCenterSprite;
  }

  int get totalCoins => currentStage.coinSpawnPoints.length;

  Vector2 get playerSpawn => currentStage.playerSpawn.clone();

  Component _trackStageComponent(Component component) {
    _stageComponents.add(component);
    return component;
  }

  Future<void> loadStage(int stageIndex) async {
    _clearStageComponents();
    _overrideStageData = null;
    _currentStageIndex = stageIndex;
    surfaces = currentStage.surfaces
        .map((surface) => PlatformSurface(
              position: surface.position.clone(),
              size: surface.size.clone(),
            ))
        .toList();
    _background.size = Vector2(worldWidth, worldHeight);

    _buildTerrainVisuals();

    exitGate = ExitGate(
      position: currentStage.exitPosition.clone(),
      size: Vector2(48, 64),
    );
    add(_trackStageComponent(exitGate));
    spawnCoins();
    spawnHearts();
    spawnStars();
    spawnSpikes();
    spawnSaws();
    spawnCheckpoints();
    spawnSprings();
    spawnWalls();
    spawnMovingPlatforms();
    spawnVerticalMovingPlatforms();
    spawnDisappearingPlatforms();
    spawnTestPortals();
  }

  Future<void> loadHubStage(LevelData stageData) async {
    await _loadOverrideStage(stageData);
  }

  Future<void> loadCustomStage(LevelData stageData) async {
    await _loadOverrideStage(stageData);
  }

  Future<void> _loadOverrideStage(LevelData stageData) async {
    _clearStageComponents();
    _overrideStageData = stageData;
    surfaces = currentStage.surfaces
        .map((surface) => PlatformSurface(
              position: surface.position.clone(),
              size: surface.size.clone(),
            ))
        .toList();
    _background.size = Vector2(worldWidth, worldHeight);

    _buildTerrainVisuals();

    exitGate = ExitGate(
      position: currentStage.exitPosition.clone(),
      size: Vector2(48, 64),
    );
    add(_trackStageComponent(exitGate));
    spawnCoins();
    spawnHearts();
    spawnStars();
    spawnSpikes();
    spawnSaws();
    spawnCheckpoints();
    spawnSprings();
    spawnWalls();
    spawnMovingPlatforms();
    spawnVerticalMovingPlatforms();
    spawnDisappearingPlatforms();
    spawnTestPortals();
  }

  Future<void> loadNextStage() async {
    if (!hasNextStage) {
      return;
    }
    await loadStage(_currentStageIndex + 1);
  }

  void _clearStageComponents() {
    for (final component in _stageComponents) {
      component.removeFromParent();
    }
    _stageComponents.clear();
    coins.clear();
    hearts.clear();
    stars.clear();
    spikes.clear();
    saws.clear();
    checkpoints.clear();
    springs.clear();
    walls.clear();
    movingPlatforms.clear();
    verticalMovingPlatforms.clear();
    disappearingPlatforms.clear();
    testPortals.clear();
  }

  void spawnCoins() {
    coins.clear();

    for (final spawnPoint in currentStage.coinSpawnPoints) {
      final coin = Coin(position: spawnPoint.clone(), size: Vector2.all(22));

      coins.add(coin);
      add(_trackStageComponent(coin));
    }
  }

  void spawnHearts() {
    hearts.clear();

    for (final spawnPoint in currentStage.heartSpawnPoints) {
      final heart = HeartPickup(position: spawnPoint.clone(), size: Vector2.all(28));

      hearts.add(heart);
      add(_trackStageComponent(heart));
    }
  }

  void spawnStars() {
    stars.clear();

    for (final spawnPoint in currentStage.starSpawnPoints) {
      final star = StarPickup(position: spawnPoint.clone(), size: Vector2.all(30));

      stars.add(star);
      add(_trackStageComponent(star));
    }
  }

  void spawnSpikes() {
    spikes.clear();

    for (final spawnPoint in currentStage.spikeSpawnPoints) {
      final spike = Spike(position: spawnPoint.clone(), size: Vector2(32, 30));

      spikes.add(spike);
      add(_trackStageComponent(spike));
    }
  }

  void spawnSaws() {
    saws.clear();

    for (final spawnPoint in currentStage.sawSpawnPoints) {
      final saw = Saw(position: spawnPoint.clone(), size: Vector2.all(34));

      saws.add(saw);
      add(_trackStageComponent(saw));
    }
  }

  void spawnCheckpoints() {
    checkpoints.clear();

    for (final definition in currentStage.checkpoints) {
      final checkpoint = Checkpoint(
        position: definition.position.clone(),
        size: definition.size.clone(),
        respawnPosition: definition.respawnPosition.clone(),
      );

      checkpoints.add(checkpoint);
      add(_trackStageComponent(checkpoint));
    }
  }

  void spawnSprings() {
    springs.clear();

    for (final spawnPoint in currentStage.springSpawnPoints) {
      final spring = Spring(position: spawnPoint.clone(), size: Vector2(32, 32));
      springs.add(spring);
      add(_trackStageComponent(spring));
    }
  }

  void spawnWalls() {
    walls.clear();

    for (final definition in currentStage.walls) {
      final wall = StoneWall(
        position: definition.position.clone(),
        size: definition.size.clone(),
        variant: definition.variant,
      );

      walls.add(wall);
      add(_trackStageComponent(wall));
    }
  }

  void spawnMovingPlatforms() {
    movingPlatforms.clear();

    for (final definition in currentStage.movingPlatforms) {
      final platform = MovingPlatform(
        position: definition.position.clone(),
        size: definition.size.clone(),
        startPosition: definition.startPosition.clone(),
        travelDistance: definition.travelDistance,
        speed: definition.speed,
      );

      movingPlatforms.add(platform);
      add(_trackStageComponent(platform));
    }
  }

  void spawnVerticalMovingPlatforms() {
    verticalMovingPlatforms.clear();

    for (final definition in currentStage.verticalMovingPlatforms) {
      final platform = VerticalMovingPlatform(
        position: definition.position.clone(),
        size: definition.size.clone(),
        startPosition: definition.startPosition.clone(),
        travelDistance: definition.travelDistance,
        speed: definition.speed,
        startsMovingUp: definition.startsMovingUp,
      );

      verticalMovingPlatforms.add(platform);
      add(_trackStageComponent(platform));
    }
  }

  void spawnDisappearingPlatforms() {
    disappearingPlatforms.clear();

    for (final definition in currentStage.disappearingPlatforms) {
      final platform = DisappearingPlatform(
        position: definition.position.clone(),
        size: definition.size.clone(),
        collapseDelay: definition.collapseDelay,
        respawnDelay: definition.respawnDelay,
      );

      disappearingPlatforms.add(platform);
      add(_trackStageComponent(platform));
    }
  }

  void spawnTestPortals() {
    testPortals.clear();

    for (final definition in currentStage.testPortals) {
      final portal = TestPortal(
        position: definition.position.clone(),
        size: definition.size.clone(),
        targetStageIndex: definition.targetStageIndex,
      );

      testPortals.add(portal);
      add(_trackStageComponent(portal));
    }
  }

  Future<void> resetState() async {
    _clearStageComponents();
    surfaces = [];
    final overrideStageData = _overrideStageData;
    if (overrideStageData != null) {
      await loadCustomStage(overrideStageData);
      return;
    }

    await loadStage(_currentStageIndex);
  }
}
