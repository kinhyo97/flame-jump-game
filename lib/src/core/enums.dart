// 프로젝트 전역에서 재사용할 enum을 모아두는 코어 타입 정의 파일.
enum PlayerState {
  idle,
  run,
  jump,
  fall,
  duck,
  climb,
  hit,
  dead,
}

enum GameMode {
  platformAdventure,
  jumpChallenge,
}
