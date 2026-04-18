// 점프, 코인, 클리어 같은 효과음을 재생하는 오디오 시스템 파일.
import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

enum SoundEffect { jump, coin, clear, hurt }

class AudioSystem {
  final Map<SoundEffect, AudioPool> _pools = {};

  Future<void> load({
    required String jumpAsset,
    required String coinAsset,
    required String clearAsset,
    required String hurtAsset,
  }) async {
    await _createPool(SoundEffect.jump, jumpAsset, maxPlayers: 3);
    await _createPool(SoundEffect.coin, coinAsset, maxPlayers: 3);
    await _createPool(SoundEffect.clear, clearAsset, maxPlayers: 2);
    await _createPool(SoundEffect.hurt, hurtAsset, maxPlayers: 2);
  }

  Future<void> _createPool(
    SoundEffect effect,
    String asset, {
    required int maxPlayers,
  }) async {
    try {
      final pool = await FlameAudio.createPool(
        asset,
        minPlayers: 1,
        maxPlayers: maxPlayers,
      );
      _pools[effect] = pool;
    } catch (error, stackTrace) {
      debugPrint('Audio pool creation failed for $effect ($asset): $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> play(SoundEffect effect) async {
    final pool = _pools[effect];
    if (pool == null) {
      return;
    }

    unawaited(_startPool(effect, pool));
  }

  Future<void> _startPool(SoundEffect effect, AudioPool pool) async {
    try {
      await pool.start();
    } catch (error, stackTrace) {
      debugPrint('Audio playback failed for $effect: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> dispose() async {
    for (final pool in _pools.values) {
      await pool.dispose();
    }
    _pools.clear();
  }
}
