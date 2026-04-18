// 게임에서 사용하는 이미지와 사운드 에셋 경로를 한곳에 모아둔 파일.
final class ImageAssets {
  const ImageAssets._();

  static const backgroundSky = 'backgrounds/background_solid_sky.png';
  static const terrainGrassBlockTopLeft = 'terrain/terrain_grass_block_top_left.png';
  static const terrainGrassBlockTop = 'terrain/terrain_grass_block_top.png';
  static const terrainGrassBlockTopRight = 'terrain/terrain_grass_block_top_right.png';
  static const terrainGrassBlockLeft = 'terrain/terrain_grass_block_left.png';
  static const terrainGrassBlockCenter = 'terrain/terrain_grass_block_center.png';
  static const terrainGrassBlockRight = 'terrain/terrain_grass_block_right.png';
  static const terrainGrassBlockBottomLeft = 'terrain/terrain_grass_block_bottom_left.png';
  static const terrainGrassBlockBottom = 'terrain/terrain_grass_block_bottom.png';
  static const terrainGrassBlockBottomRight = 'terrain/terrain_grass_block_bottom_right.png';
  static const terrainGrassHorizontalLeft = 'terrain/terrain_grass_horizontal_left.png';
  static const terrainGrassHorizontalMiddle = 'terrain/terrain_grass_horizontal_middle.png';
  static const terrainGrassHorizontalRight = 'terrain/terrain_grass_horizontal_right.png';
  static const coinGold = 'items/coin_gold.png';
  static const coinGoldSide = 'items/coin_gold_side.png';
  static const doorClosed = 'props/door_closed.png';
  static const doorOpen = 'props/door_open.png';
  static const checkpointInactive = 'items/flag_off.png';
  static const checkpointActive = 'items/flag_green_a.png';
  static const movingPlatform = 'props/bridge.png';
  static const springIdle = 'props/spring.png';
  static const springActive = 'props/spring_out.png';
  static const lava = 'hazards/lava.png';
  static const lavaTop = 'hazards/lava_top.png';
  static const lavaTopLow = 'hazards/lava_top_low.png';
  static const saw = 'hazards/saw.png';
  static const spikes = 'hazards/spikes.png';

  static const playerGreenIdle = 'player/character_green_idle.png';
  static const playerGreenJump = 'player/character_green_jump.png';
  static const playerGreenWalkA = 'player/character_green_walk_a.png';
  static const playerGreenWalkB = 'player/character_green_walk_b.png';
}

final class AudioAssets {
  const AudioAssets._();

  static const jump = 'sfx/sfx_jump.wav';
  static const coin = 'sfx/sfx_coin.wav';
  static const clear = 'sfx/sfx_gem.wav';
  static const hurt = 'sfx/sfx_coin.wav';
}
