import 'package:flutter/material.dart';

import '../game/jump_game.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final JumpGame game;

  @override
  Widget build(BuildContext context) {
    final shouldRestartFromFirstRound =
        !game.shouldRetryCurrentStageOnClear && game.level.currentStageNumber > 1;

    return ColoredBox(
      color: const Color(0xCC10151F),
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF223047),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF8A80), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                shouldRestartFromFirstRound
                    ? '다시 시작하면 Round 1으로 돌아갑니다.'
                    : 'Round ${game.level.currentStageNumber} / ${game.level.totalStages}',
                style: const TextStyle(
                  color: Color(0xFFFFB4A9),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Collected ${game.coinsCollected} / ${game.level.totalCoins} coins',
                style: const TextStyle(color: Color(0xFFD6E2F0), fontSize: 18),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: game.restartFromFirstStage,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A80),
                    foregroundColor: const Color(0xFF1A2233),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Restart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
