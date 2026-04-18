// 플레이어가 닿았을 때 반응하는 상호작용 오브젝트의 공통 베이스를 정의하는 파일.
import 'game_entity.dart';

abstract class Interactable extends GameEntity {
  Interactable({
    super.position,
    super.size,
  });
}
