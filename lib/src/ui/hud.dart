import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

import '../core/constants.dart';

class Hud extends PositionComponent {
  Hud();

  static const _maxLives = 3;
  static const _heartSize = 34.0;
  static const _heartGap = 8.0;
  static const _heartTop = 18.0;

  late final TextComponent _roundLabel;
  late final TextComponent _coinLabel;
  late final TextComponent _starLabel;
  late final TextComponent _goalLabel;
  late final Sprite _filledHeartSprite;
  late final Sprite _emptyHeartSprite;
  late final List<SpriteComponent> _lifeIcons;
  String? _lastRoundText;
  int? _lastCoinCount;
  int? _lastLivesCount;
  int? _lastInvincibleSeconds;
  int? _lastRemainingCoins;
  bool _isExitOpen = false;
  bool _isLevelCleared = false;

  @override
  Future<void> onLoad() async {
    _filledHeartSprite = await Sprite.load('ui/hud_heart.png');
    _emptyHeartSprite = await Sprite.load('ui/hud_heart_empty.png');

    _roundLabel = TextComponent(
      position: Vector2(24, 18),
      text: 'Round 1 / 1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF8BD3FF),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    _coinLabel = TextComponent(
      position: Vector2(24, 46),
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
      position: Vector2(24, 108),
      text: 'Exit locked: collect 0 more coins',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFE082),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    _starLabel = TextComponent(
      position: Vector2(24, 76),
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFF176),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    _lifeIcons = List.generate(
      _maxLives,
      (_) => SpriteComponent(
        size: Vector2.all(_heartSize),
      ),
    );

    add(_roundLabel);
    add(_coinLabel);
    add(_starLabel);
    add(_goalLabel);
    for (final icon in _lifeIcons) {
      add(icon);
    }

    _layoutLivesIcons();
    setLivesCount(_maxLives);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layoutLivesIcons();
  }

  void setRound(int current, int total) {
    final nextText = 'Round $current / $total';
    if (_lastRoundText == nextText) {
      return;
    }
    _lastRoundText = nextText;
    _roundLabel.text = nextText;
  }

  void setCoinCount(int count) {
    if (_lastCoinCount == count) {
      return;
    }
    _lastCoinCount = count;
    _coinLabel.text = 'Coins: $count';
  }

  void setLivesCount(int count) {
    if (_lastLivesCount == count) {
      return;
    }
    _lastLivesCount = count;
    final safeCount = count.clamp(0, _maxLives);
    for (var index = 0; index < _lifeIcons.length; index++) {
      _lifeIcons[index].sprite =
          index < safeCount ? _filledHeartSprite : _emptyHeartSprite;
    }
  }

  void setInvincibilityTime(double secondsRemaining) {
    final safeSeconds = secondsRemaining <= 0 ? 0 : secondsRemaining.ceil();
    if (_lastInvincibleSeconds == safeSeconds) {
      return;
    }

    _lastInvincibleSeconds = safeSeconds;
    _starLabel.text = safeSeconds > 0 ? 'Star: ${safeSeconds}s' : '';
  }

  void setExitLocked(int remainingCoins) {
    if (!_isExitOpen && !_isLevelCleared && _lastRemainingCoins == remainingCoins) {
      return;
    }
    _isExitOpen = false;
    _isLevelCleared = false;
    _lastRemainingCoins = remainingCoins;
    _goalLabel.text = 'Exit locked: collect $remainingCoins more coins';
  }

  void setExitOpen() {
    if (_isExitOpen && !_isLevelCleared) {
      return;
    }
    _isExitOpen = true;
    _isLevelCleared = false;
    _goalLabel.text = 'Exit open: reach the door';
  }

  void setLevelCleared() {
    if (_isLevelCleared) {
      return;
    }
    _isLevelCleared = true;
    _goalLabel.text = 'Level clear!';
  }

  void _layoutLivesIcons() {
    final totalWidth =
        (_heartSize * _maxLives) + (_heartGap * (_maxLives - 1));
    final left = (GameConstants.resolution.x - totalWidth) / 2;

    for (var index = 0; index < _lifeIcons.length; index++) {
      _lifeIcons[index].position = Vector2(
        left + index * (_heartSize + _heartGap),
        _heartTop,
      );
    }
  }
}
