// 플레이어에게 위험 판정을 주는 장애물 계열의 공통 베이스를 정의하는 파일.
import 'game_entity.dart';
import 'package:flutter/rendering.dart';

abstract class Hazard extends GameEntity {
  Hazard({
    super.position,
    super.size,
  });

  Rect get bounds;
}
