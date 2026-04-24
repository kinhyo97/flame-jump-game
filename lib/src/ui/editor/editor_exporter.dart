import '../../world/level_models.dart';

String buildLevelDataExport({
  required LevelData level,
  String variableName = 'editorExportLevelData',
}) {
  final buffer = StringBuffer()
    ..writeln("import 'package:flame/components.dart';")
    ..writeln()
    ..writeln("import '../level_models.dart';")
    ..writeln("import '../platform_surface.dart';")
    ..writeln()
    ..writeln('final LevelData $variableName = LevelData(')
    ..writeln('  worldWidth: ${_double(level.worldWidth)},')
    ..writeln('  playerSpawn: ${_vector(level.playerSpawn)},')
    ..writeln('  exitPosition: ${_vector(level.exitPosition)},')
    ..writeln('  surfaces: [');

  for (final surface in level.surfaces) {
    buffer.writeln(
      '    PlatformSurface(position: ${_vector(surface.position)}, size: ${_vector(surface.size)}),',
    );
  }

  buffer
    ..writeln('  ],')
    ..writeln('  coinSpawnPoints: [');

  for (final coin in level.coinSpawnPoints) {
    buffer.writeln('    ${_vector(coin)},');
  }

  buffer
    ..writeln('  ],')
    ..writeln('  heartSpawnPoints: [');

  for (final heart in level.heartSpawnPoints) {
    buffer.writeln('    ${_vector(heart)},');
  }

  buffer
    ..writeln('  ],')
    ..writeln('  starSpawnPoints: [');

  for (final star in level.starSpawnPoints) {
    buffer.writeln('    ${_vector(star)},');
  }

  buffer
    ..writeln('  ],')
    ..writeln('  spikeSpawnPoints: [');

  for (final spike in level.spikeSpawnPoints) {
    buffer.writeln('    ${_vector(spike)},');
  }

  buffer
    ..writeln('  ],')
    ..writeln('  sawSpawnPoints: [');

  for (final saw in level.sawSpawnPoints) {
    buffer.writeln('    ${_vector(saw)},');
  }

  buffer
    ..writeln('  ],')
    ..writeln('  checkpoints: [');

  for (final checkpoint in level.checkpoints) {
    buffer.writeln('    CheckpointData(');
    buffer.writeln('      position: ${_vector(checkpoint.position)},');
    buffer.writeln('      size: ${_vector(checkpoint.size)},');
    buffer.writeln(
      '      respawnPosition: ${_vector(checkpoint.respawnPosition)},',
    );
    buffer.writeln('    ),');
  }

  buffer
    ..writeln('  ],')
    ..writeln('  springSpawnPoints: [');

  for (final spring in level.springSpawnPoints) {
    buffer.writeln('    ${_vector(spring)},');
  }

  buffer
    ..writeln('  ],')
    ..writeln('  walls: [');

  for (final wall in level.walls) {
    buffer.writeln(
      '    WallData(position: ${_vector(wall.position)}, size: ${_vector(wall.size)}, variant: WallSegmentVariant.${wall.variant.name}),',
    );
  }

  buffer
    ..writeln('  ],')
    ..writeln('  movingPlatforms: [');

  for (final platform in level.movingPlatforms) {
    buffer.writeln('    MovingPlatformData(');
    buffer.writeln('      position: ${_vector(platform.position)},');
    buffer.writeln('      size: ${_vector(platform.size)},');
    buffer.writeln('      startPosition: ${_vector(platform.startPosition)},');
    buffer.writeln('      travelDistance: ${_double(platform.travelDistance)},');
    buffer.writeln('      speed: ${_double(platform.speed)},');
    buffer.writeln('    ),');
  }

  buffer
    ..writeln('  ],')
    ..writeln('  verticalMovingPlatforms: [');

  for (final platform in level.verticalMovingPlatforms) {
    buffer.writeln('    VerticalMovingPlatformData(');
    buffer.writeln('      position: ${_vector(platform.position)},');
    buffer.writeln('      size: ${_vector(platform.size)},');
    buffer.writeln('      startPosition: ${_vector(platform.startPosition)},');
    buffer.writeln('      travelDistance: ${_double(platform.travelDistance)},');
    buffer.writeln('      speed: ${_double(platform.speed)},');
    buffer.writeln('      startsMovingUp: ${platform.startsMovingUp},');
    buffer.writeln('    ),');
  }

  buffer
    ..writeln('  ],')
    ..writeln('  disappearingPlatforms: [');

  for (final platform in level.disappearingPlatforms) {
    buffer.writeln('    DisappearingPlatformData(');
    buffer.writeln('      position: ${_vector(platform.position)},');
    buffer.writeln('      size: ${_vector(platform.size)},');
    buffer.writeln('      collapseDelay: ${_double(platform.collapseDelay)},');
    buffer.writeln('      respawnDelay: ${_double(platform.respawnDelay)},');
    buffer.writeln('    ),');
  }

  buffer
    ..writeln('  ],')
    ..writeln('  testPortals: [');

  for (final portal in level.testPortals) {
    buffer.writeln('    TestPortalData(');
    buffer.writeln('      position: ${_vector(portal.position)},');
    buffer.writeln('      size: ${_vector(portal.size)},');
    buffer.writeln('      targetStageIndex: ${portal.targetStageIndex},');
    buffer.writeln('    ),');
  }

  buffer
    ..writeln('  ],')
    ..writeln(');');

  return buffer.toString();
}

String _vector(dynamic vector) {
  return 'Vector2(${_double(vector.x)}, ${_double(vector.y)})';
}

String _double(double value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}
