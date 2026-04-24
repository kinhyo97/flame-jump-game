enum PlayerSkin { classic, whale, bazzi }

const availablePlayerSkins = [
  PlayerSkin.classic,
  PlayerSkin.whale,
];

extension PlayerSkinX on PlayerSkin {
  String get label => switch (this) {
    PlayerSkin.classic => 'Classic',
    PlayerSkin.whale => 'Whale',
    PlayerSkin.bazzi => 'Bazzi',
  };

  String get subtitle => switch (this) {
    PlayerSkin.classic => 'Default jump game character',
    PlayerSkin.whale => 'New whale character',
    PlayerSkin.bazzi => 'Hidden Bazzi asset',
  };

  String get previewAssetPath => switch (this) {
    PlayerSkin.classic => 'assets/images/player/character_green_front.png',
    PlayerSkin.whale => 'assets/images/player/whale_idle_256px.png',
    PlayerSkin.bazzi => 'assets/images/player/bazzi/bazzi_idle.png',
  };
}
