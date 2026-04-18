// 속도와 상태를 가진 이동형 엔티티의 공통 베이스를 정의하는 파일.
import 'package:flame/extensions.dart';

import 'game_entity.dart';

abstract class Actor extends GameEntity {
  Actor({
    super.position,
    super.size,
  });

  final Vector2 velocity = Vector2.zero();
}
