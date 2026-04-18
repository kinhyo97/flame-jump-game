// 플레이어가 획득할 수 있는 수집형 오브젝트의 공통 베이스를 정의하는 파일.
import 'game_entity.dart';

abstract class Collectible extends GameEntity {
  Collectible({
    super.position,
    super.size,
  });
}
