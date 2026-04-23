import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../game/jump_game.dart';

class MobileControlsOverlay extends StatefulWidget {
  const MobileControlsOverlay({required this.game, super.key});

  final JumpGame game;

  @override
  State<MobileControlsOverlay> createState() => _MobileControlsOverlayState();
}

class _MobileControlsOverlayState extends State<MobileControlsOverlay> {
  static const _joystickBaseAsset =
      'assets/mobile-controls/Sprites/Style G/Default/joystick_circle_pad_a.png';
  static const _jumpButtonAsset =
      'assets/mobile-controls/Sprites/Style G/Default/button_circle.png';
  Offset _joystickOffset = Offset.zero;
  bool _jumpHeld = false;
  int? _activeJoystickPointerId;
  int? _activeJumpPointerId;

  bool get _showControls {
    if (kIsWeb) {
      return true;
    }

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return true;
    }

    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide < 700;
  }

  @override
  Widget build(BuildContext context) {
    if (!_showControls) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final isCompactMobile = screenSize.width < 900;
    final jumpButtonSize = isCompactMobile ? 108.0 : 132.0;
    final joystickSize = jumpButtonSize;
    final nubSize = joystickSize * 0.56;
    final maxOffset = joystickSize * 0.26;
    final horizontalPadding = isCompactMobile ? 18.0 : 28.0;
    final leftControlInset = isCompactMobile ? 18.0 : 24.0;
    final topPadding = isCompactMobile ? 12.0 : 24.0;
    final bottomPadding = isCompactMobile ? 14.0 : 26.0;

    return IgnorePointer(
      ignoring: false,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding,
              horizontalPadding,
              bottomPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: leftControlInset),
                  child: _buildJoystick(joystickSize, nubSize, maxOffset),
                ),
                const Spacer(),
                _buildJumpButton(jumpButtonSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJoystick(double joystickSize, double nubSize, double maxOffset) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        if (_activeJoystickPointerId != null) {
          return;
        }
        _activeJoystickPointerId = event.pointer;
        _updateJoystick(event.localPosition, joystickSize, maxOffset);
      },
      onPointerMove: (event) {
        if (_activeJoystickPointerId != event.pointer) {
          return;
        }
        _updateJoystick(event.localPosition, joystickSize, maxOffset);
      },
      onPointerUp: (event) {
        if (_activeJoystickPointerId != event.pointer) {
          return;
        }
        _activeJoystickPointerId = null;
        _resetJoystick();
      },
      onPointerCancel: (event) {
        if (_activeJoystickPointerId != event.pointer) {
          return;
        }
        _activeJoystickPointerId = null;
        _resetJoystick();
      },
      child: SizedBox(
        width: joystickSize,
        height: joystickSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              _joystickBaseAsset,
              width: joystickSize,
              height: joystickSize,
            ),
            Transform.translate(
              offset: _joystickOffset,
              child: Container(
                width: nubSize,
                height: nubSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.28, -0.35),
                    radius: 1.05,
                    colors: [
                      Color(0xCCFFFFFF),
                      Color(0x883B495F),
                      Color(0x66303D52),
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                  border: Border.all(
                    color: const Color(0x99FFFFFF),
                    width: 1.4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44212B39),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Color(0x22FFFFFF),
                      blurRadius: 10,
                      spreadRadius: -2,
                      offset: Offset(-3, -3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: nubSize * 0.19,
                      top: nubSize * 0.16,
                      child: Container(
                        width: nubSize * 0.24,
                        height: nubSize * 0.24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x66FFFFFF),
                        ),
                      ),
                    ),
                    Positioned(
                      right: nubSize * 0.21,
                      bottom: nubSize * 0.19,
                      child: Container(
                        width: nubSize * 0.22,
                        height: nubSize * 0.22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x22303D52),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJumpButton(double jumpButtonSize) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        if (_activeJumpPointerId != null) {
          return;
        }
        _activeJumpPointerId = event.pointer;
        _handleJumpDown();
      },
      onPointerUp: (event) {
        if (_activeJumpPointerId != event.pointer) {
          return;
        }
        _activeJumpPointerId = null;
        _handleJumpUp();
      },
      onPointerCancel: (event) {
        if (_activeJumpPointerId != event.pointer) {
          return;
        }
        _activeJumpPointerId = null;
        _handleJumpUp();
      },
      child: SizedBox(
        width: jumpButtonSize,
        height: jumpButtonSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: _jumpHeld ? 0.82 : 1,
              child: Image.asset(
                _jumpButtonAsset,
                width: jumpButtonSize,
                height: jumpButtonSize,
              ),
            ),
            Icon(
              Icons.arrow_upward_rounded,
              size: jumpButtonSize * 0.34,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _updateJoystick(
    Offset localPosition,
    double joystickSize,
    double maxOffset,
  ) {
    final center = Offset(joystickSize / 2, joystickSize / 2);
    final delta = localPosition - center;
    final distance = delta.distance;

    final limitedDelta = distance > maxOffset && distance > 0
        ? delta / distance * maxOffset
        : delta;

    final horizontal = (limitedDelta.dx / maxOffset).clamp(-1.0, 1.0);
    widget.game.inputSystem.setTouchHorizontal(horizontal);

    if (!mounted) {
      return;
    }

    setState(() {
      _joystickOffset = Offset(limitedDelta.dx, limitedDelta.dy);
    });
  }

  void _resetJoystick() {
    widget.game.inputSystem.setTouchHorizontal(0);

    if (!mounted) {
      return;
    }

    setState(() {
      _joystickOffset = Offset.zero;
    });
  }

  void _resetJoystickWithoutRebuild() {
    widget.game.inputSystem.setTouchHorizontal(0);
    _joystickOffset = Offset.zero;
  }

  void _handleJumpDown() {
    widget.game.inputSystem.queueJump();

    if (!mounted) {
      return;
    }

    setState(() {
      _jumpHeld = true;
    });
  }

  void _handleJumpUp() {
    if (!mounted) {
      return;
    }

    setState(() {
      _jumpHeld = false;
    });
  }

  @override
  void deactivate() {
    _activeJoystickPointerId = null;
    _activeJumpPointerId = null;
    _resetJoystickWithoutRebuild();
    _jumpHeld = false;
    super.deactivate();
  }
}
