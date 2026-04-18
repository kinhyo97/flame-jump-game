// 월드에 배치되는 모든 게임 오브젝트의 가장 기본이 되는 엔티티 파일.
import 'package:flame/components.dart';

abstract class GameEntity extends PositionComponent {
  GameEntity({
    super.position,
    super.size,
  });
}
