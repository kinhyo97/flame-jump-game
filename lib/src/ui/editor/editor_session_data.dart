import 'package:flame/components.dart';

import '../../world/level_models.dart';
import '../../world/platform_surface.dart';

class EditorSessionData {
  EditorSessionData({
    required this.surfaces,
    required this.coins,
    required this.hearts,
    required this.stars,
    required this.spikes,
    required this.saws,
    required this.checkpoints,
    required this.springs,
    required this.walls,
    required this.disappearingPlatforms,
  });

  final List<PlatformSurface> surfaces;
  final List<Vector2> coins;
  final List<Vector2> hearts;
  final List<Vector2> stars;
  final List<Vector2> spikes;
  final List<Vector2> saws;
  final List<CheckpointData> checkpoints;
  final List<Vector2> springs;
  final List<WallData> walls;
  final List<DisappearingPlatformData> disappearingPlatforms;
}
