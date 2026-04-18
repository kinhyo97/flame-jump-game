// 키보드나 터치 입력을 공통 상태로 모아 플레이어 로직에 전달하는 입력 관리 파일.
class InputSystem {
  double horizontal = 0;
  bool jumpPressed = false;
  bool moveLeftHeld = false;
  bool moveRightHeld = false;

  void resetFrameInput() {
    jumpPressed = false;
  }

  void setMoveLeft(bool isPressed) {
    moveLeftHeld = isPressed;
    _syncHorizontal();
  }

  void setMoveRight(bool isPressed) {
    moveRightHeld = isPressed;
    _syncHorizontal();
  }

  void queueJump() {
    jumpPressed = true;
  }

  void _syncHorizontal() {
    horizontal = (moveRightHeld ? 1.0 : 0.0) - (moveLeftHeld ? 1.0 : 0.0);
  }
}
