import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import 'exit_gate.dart';

class TestPortal extends PositionComponent {
  TestPortal({
    required super.position,
    required super.size,
    required this.targetStageIndex,
  });

  final int targetStageIndex;

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  Future<void> onLoad() async {
    final gate = ExitGate(position: Vector2.zero(), size: size);
    await add(gate);
    gate.openGate();

    await add(
      TextComponent(
        text: 'R${targetStageIndex + 1}',
        anchor: Anchor.bottomCenter,
        position: Vector2(size.x / 2, -10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
