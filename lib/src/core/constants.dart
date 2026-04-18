// 게임 해상도와 플레이어 이동/점프 수치 같은 전역 설정값을 모아두는 파일.
import 'package:flame/extensions.dart';

final class GameConstants {
  const GameConstants._();

  static final resolution = Vector2(1280, 720);
  static const aspectRatio = 16 / 9;
  static const backgroundColor = 0xFF202A3B;
  static const floorHeight = 96.0;
  static const levelWidth = 2240.0;
  static const levelHeight = 720.0;
  static const cameraFollowSpeed = 900.0;
}

final class PlayerConstants {
  const PlayerConstants._();

  static final spawn = Vector2(160, 520);
  static final size = Vector2(48, 48);
  static const runAcceleration = 2200.0;
  static const runDeceleration = 2600.0;
  static const maxRunSpeed = 320.0;
  static const jumpSpeed = 720.0;
  static const springJumpSpeed = 980.0;
  static const gravity = 1900.0;
  static const fallGravityMultiplier = 1.35;
  static const maxFallSpeed = 900.0;
}
