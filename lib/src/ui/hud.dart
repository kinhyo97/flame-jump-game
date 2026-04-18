// 코인 수처럼 현재 플레이 정보를 화면에 표시하는 HUD 파일.
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

class Hud extends PositionComponent {
  Hud();

  late final TextComponent _coinLabel;
  late final TextComponent _goalLabel;

  @override
  Future<void> onLoad() async {
    _coinLabel = TextComponent(
      position: Vector2(24, 18),
      text: 'Coins: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    _goalLabel = TextComponent(
      position: Vector2(24, 50),
      text: 'Exit locked: collect 0 more coins',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFE082),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    add(_coinLabel);
    add(_goalLabel);
  }

  void setCoinCount(int count) {
    _coinLabel.text = 'Coins: $count';
  }

  void setExitLocked(int remainingCoins) {
    _goalLabel.text = 'Exit locked: collect $remainingCoins more coins';
  }

  void setExitOpen() {
    _goalLabel.text = 'Exit open: reach the door';
  }

  void setLevelCleared() {
    _goalLabel.text = 'Level clear!';
  }
}
