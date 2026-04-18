// 적 엔티티들이 공통으로 상속할 베이스 적 클래스 파일.
import '../base/actor.dart';

abstract class Enemy extends Actor {
  Enemy({
    super.position,
    super.size,
  });
}
