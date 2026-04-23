export 'level_models.dart';
export 'platform_surface.dart';

import 'level_models.dart';
import 'levels/level_1_data.dart';
import 'levels/level_2_data.dart';
import 'levels/level_3_data.dart';
import 'levels/level_4_data.dart';
import 'levels/level_5_data.dart';
import 'levels/level_6_data.dart';

export 'levels/map_test_hub_level.dart';

final List<LevelData> gameLevels = [
  level1Data,
  level2Data,
  level3Data,
  level4Data,
  level5Data,
  level6Data,
];
