// 레벨 클리어 시 표시되는 오버레이 UI 파일.
import 'package:flutter/material.dart';

import '../game/jump_game.dart';

class ClearOverlay extends StatelessWidget {
  const ClearOverlay({super.key, required this.game});

  final JumpGame game;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xAA10151F),
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF223047),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFE082), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Level Clear!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Collected ${game.coinsCollected} / ${game.level.totalCoins} coins',
                style: const TextStyle(color: Color(0xFFD6E2F0), fontSize: 18),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: game.resetLevel,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC857),
                    foregroundColor: const Color(0xFF1A2233),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
