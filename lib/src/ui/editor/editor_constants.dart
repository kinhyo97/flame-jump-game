import '../../core/constants.dart';

final class EditorConstants {
  const EditorConstants._();

  static const worldWidth = GameConstants.levelWidth;
  static const worldHeight = GameConstants.levelHeight;
  static const tileSize = 32.0;
  static const gridYOffset = (worldHeight - GameConstants.floorHeight) % tileSize;
  static const newSurfaceWidth = 128.0;
  static const newSurfaceHeight = 28.0;
  static const coinSize = 22.0;
  static const heartSize = 28.0;
  static const starSize = 30.0;
  static const coinSnapStep = 4.0;
  static const objectSnapStep = 4.0;
  static const spikeWidth = 32.0;
  static const spikeHeight = 30.0;
  static const sawSize = 34.0;
  static const checkpointWidth = 24.0;
  static const checkpointHeight = 64.0;
  static const springSize = 32.0;
  static const wallWidth = 32.0;
  static const wallHeight = 32.0;
  static const disappearingPlatformWidth = 96.0;
  static const disappearingPlatformHeight = 28.0;
}
