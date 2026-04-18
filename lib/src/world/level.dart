// 월드 바닥과 이후 발판/오브젝트 배치의 기준이 되는 기본 레벨 파일.
import 'package:flame/components.dart';

import '../core/assets.dart';
import '../core/constants.dart';
import '../entities/hazards/saw.dart';
import '../entities/hazards/spike.dart';
import '../entities/items/coin.dart';
import '../entities/objects/checkpoint.dart';
import '../entities/objects/exit_gate.dart';
import '../entities/objects/moving_platform.dart';
import '../entities/objects/spring.dart';
import '../game/jump_game.dart';

class PlatformSurface {
  const PlatformSurface({required this.position, required this.size});

  final Vector2 position;
  final Vector2 size;

  double get left => position.x;
  double get right => position.x + size.x;
  double get top => position.y;
  double get bottom => position.y + size.y;
}

class Level extends PositionComponent with HasGameReference<JumpGame> {
  Level()
    : coins = [],
      spikes = [],
      saws = [],
      checkpoints = [],
      springs = [],
      movingPlatforms = [];

  static const double _tileSize = 32;

  late final List<PlatformSurface> surfaces;
  final List<Coin> coins;
  final List<Spike> spikes;
  final List<Saw> saws;
  final List<Checkpoint> checkpoints;
  final List<Spring> springs;
  final List<MovingPlatform> movingPlatforms;
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
  late final ExitGate exitGate;
  late final List<Vector2> _coinSpawnPoints;
  late final List<Vector2> _spikeSpawnPoints;
  late final List<Vector2> _sawSpawnPoints;
  late final List<Checkpoint> _checkpointDefinitions;
  late final List<Vector2> _springSpawnPoints;
  late final List<MovingPlatform> _movingPlatformDefinitions;

  double get worldWidth => GameConstants.levelWidth;
  double get worldHeight => GameConstants.levelHeight;

  @override
  Future<void> onLoad() async {
    await _loadTerrainSprites();

    surfaces = [
      PlatformSurface(
        position: Vector2(
          0,
          GameConstants.resolution.y - GameConstants.floorHeight,
        ),
        size: Vector2(GameConstants.levelWidth, GameConstants.floorHeight),
      ),
      PlatformSurface(position: Vector2(120, 540), size: Vector2(220, 28)),
      PlatformSurface(position: Vector2(420, 455), size: Vector2(210, 28)),
      PlatformSurface(position: Vector2(760, 365), size: Vector2(180, 28)),
      PlatformSurface(position: Vector2(1080, 500), size: Vector2(170, 28)),
      PlatformSurface(position: Vector2(980, 250), size: Vector2(210, 28)),
      PlatformSurface(position: Vector2(1350, 420), size: Vector2(190, 28)),
      PlatformSurface(position: Vector2(1625, 330), size: Vector2(200, 28)),
      PlatformSurface(position: Vector2(1885, 250), size: Vector2(170, 28)),
    ];

    _coinSpawnPoints = [
      Vector2(195, 490),
      Vector2(500, 405),
      Vector2(825, 315),
      Vector2(1140, 450),
      Vector2(1060, 200),
      Vector2(1425, 370),
      Vector2(1700, 280),
      Vector2(1935, 200),
    ];

    _spikeSpawnPoints = [
      Vector2(620, GameConstants.resolution.y - GameConstants.floorHeight - 30),
      Vector2(1280, GameConstants.resolution.y - GameConstants.floorHeight - 30),
      Vector2(1540, 390),
    ];

    _sawSpawnPoints = [
      Vector2(1098, 468),
      Vector2(1910, 218),
    ];

    _checkpointDefinitions = [
      Checkpoint(
        position: Vector2(900, 301),
        size: Vector2(24, 64),
        respawnPosition: Vector2(840, 317),
      ),
      Checkpoint(
        position: Vector2(1760, 266),
        size: Vector2(24, 64),
        respawnPosition: Vector2(1700, 282),
      ),
    ];

    _springSpawnPoints = [
      Vector2(700, 333),
      Vector2(1490, 388),
    ];

    _movingPlatformDefinitions = [
      MovingPlatform(
        position: Vector2(560, 285),
        size: Vector2(96, 24),
        startPosition: Vector2(560, 285),
        travelDistance: 90,
        speed: 1.8,
      ),
      MovingPlatform(
        position: Vector2(1180, 160),
        size: Vector2(96, 24),
        startPosition: Vector2(1180, 160),
        travelDistance: 110,
        speed: 1.4,
      ),
    ];

    _addBackground();
    _buildTerrainVisuals();

    exitGate = ExitGate(
      position: Vector2(
        GameConstants.levelWidth - 120,
        GameConstants.resolution.y - GameConstants.floorHeight - 64,
      ),
      size: Vector2(48, 64),
    );

    add(exitGate);
    spawnCoins();
    spawnSpikes();
    spawnSaws();
    spawnCheckpoints();
    spawnSprings();
    spawnMovingPlatforms();
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

  void _addBackground() {
    add(
      SpriteComponent(
        sprite: _backgroundSprite,
        position: Vector2.zero(),
        size: Vector2(worldWidth, worldHeight),
        priority: -100,
      ),
    );
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
          SpriteComponent(
            sprite: _groundSpriteFor(isTop, isBottom, isLeft, isRight),
            position: Vector2(
              surface.position.x + column * _tileSize,
              surface.position.y + row * _tileSize,
            ),
            size: Vector2(_tileSize, _tileSize),
            priority: -20,
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
        SpriteComponent(
          sprite: sprite,
          position: Vector2(surface.position.x + column * _tileSize, top),
          size: Vector2(_tileSize, _tileSize),
          priority: -20,
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

  int get totalCoins => _coinSpawnPoints.length;

  void spawnCoins() {
    coins.clear();

    for (final spawnPoint in _coinSpawnPoints) {
      final coin = Coin(position: spawnPoint.clone(), size: Vector2.all(22));

      coins.add(coin);
      add(coin);
    }
  }

  void spawnSpikes() {
    spikes.clear();

    for (final spawnPoint in _spikeSpawnPoints) {
      final spike = Spike(position: spawnPoint.clone(), size: Vector2(32, 30));

      spikes.add(spike);
      add(spike);
    }
  }

  void spawnSaws() {
    saws.clear();

    for (final spawnPoint in _sawSpawnPoints) {
      final saw = Saw(position: spawnPoint.clone(), size: Vector2.all(34));

      saws.add(saw);
      add(saw);
    }
  }

  void spawnCheckpoints() {
    checkpoints.clear();

    for (final definition in _checkpointDefinitions) {
      final checkpoint = Checkpoint(
        position: definition.position.clone(),
        size: definition.size.clone(),
        respawnPosition: definition.respawnPosition.clone(),
      );

      checkpoints.add(checkpoint);
      add(checkpoint);
    }
  }

  void spawnSprings() {
    springs.clear();

    for (final spawnPoint in _springSpawnPoints) {
      final spring = Spring(position: spawnPoint.clone(), size: Vector2(32, 32));
      springs.add(spring);
      add(spring);
    }
  }

  void spawnMovingPlatforms() {
    movingPlatforms.clear();

    for (final definition in _movingPlatformDefinitions) {
      final platform = MovingPlatform(
        position: definition.startPosition.clone(),
        size: definition.size.clone(),
        startPosition: definition.startPosition.clone(),
        travelDistance: definition.travelDistance,
        speed: definition.speed,
      );

      movingPlatforms.add(platform);
      add(platform);
    }
  }

  void resetState() {
    for (final coin in coins) {
      coin.removeFromParent();
    }

    for (final checkpoint in checkpoints) {
      checkpoint.deactivate();
    }

    exitGate.resetGate();
    spawnCoins();
  }
}
