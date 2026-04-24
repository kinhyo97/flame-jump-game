import 'package:flame/components.dart';

import '../../core/constants.dart';
import '../../world/level_models.dart';
import '../../world/platform_surface.dart';

LevelData? parseLevelDataCode(String source) {
  final worldWidth = _parseDoubleField(source, 'worldWidth') ??
      GameConstants.levelWidth;
  final playerSpawn = _parseSingleVector(source, 'playerSpawn');
  final exitPosition = _parseSingleVector(source, 'exitPosition');
  if (playerSpawn == null || exitPosition == null) {
    return null;
  }

  final surfaces = _parseSurfaces(source);
  final coins = _parseVectorSection(source, 'coinSpawnPoints');
  final hearts = _parseVectorSection(source, 'heartSpawnPoints');
  final stars = _parseVectorSection(source, 'starSpawnPoints');
  final spikes = _parseVectorSection(source, 'spikeSpawnPoints');
  final saws = _parseVectorSection(source, 'sawSpawnPoints');
  final checkpoints = _parseCheckpoints(source);
  final springs = _parseVectorSection(source, 'springSpawnPoints');
  final walls = _parseWalls(source);
  final movingPlatforms = _parseMovingPlatforms(source);
  final verticalMovingPlatforms = _parseVerticalMovingPlatforms(source);
  final disappearingPlatforms = _parseDisappearingPlatforms(source);
  final testPortals = _parseTestPortals(source);

  return LevelData(
    worldWidth: worldWidth,
    playerSpawn: playerSpawn,
    exitPosition: exitPosition,
    surfaces: surfaces,
    coinSpawnPoints: coins,
    heartSpawnPoints: hearts,
    starSpawnPoints: stars,
    spikeSpawnPoints: spikes,
    sawSpawnPoints: saws,
    checkpoints: checkpoints,
    springSpawnPoints: springs,
    walls: walls,
    movingPlatforms: movingPlatforms,
    verticalMovingPlatforms: verticalMovingPlatforms,
    disappearingPlatforms: disappearingPlatforms,
    testPortals: testPortals,
  );
}

Vector2? _parseSingleVector(String source, String fieldName) {
  final match = RegExp(
    '$fieldName\\s*:\\s*Vector2\\(([^,]+),\\s*([^)]+)\\)',
  ).firstMatch(source);
  if (match == null) {
    return null;
  }
  return _toVector(match.group(1), match.group(2));
}

List<Vector2> _parseVectorSection(String source, String fieldName) {
  final section = _extractSection(source, fieldName);
  if (section == null) {
    return const [];
  }

  return RegExp(r'Vector2\(([^,]+),\s*([^)]+)\)')
      .allMatches(section)
      .map((match) => _toVector(match.group(1), match.group(2)))
      .whereType<Vector2>()
      .toList();
}

List<PlatformSurface> _parseSurfaces(String source) {
  final section = _extractSection(source, 'surfaces');
  if (section == null) {
    return const [];
  }

  return RegExp(
    r'PlatformSurface\(\s*position:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*size:\s*Vector2\(([^,]+),\s*([^)]+)\)\s*\)',
    dotAll: true,
  ).allMatches(section).map((match) {
    final position = _toVector(match.group(1), match.group(2));
    final size = _toVector(match.group(3), match.group(4));
    if (position == null || size == null) {
      return null;
    }
    return PlatformSurface(position: position, size: size);
  }).whereType<PlatformSurface>().toList();
}

double? _parseDoubleField(String source, String fieldName) {
  final match = RegExp('$fieldName\\s*:\\s*([^,\\n]+)').firstMatch(source);
  if (match == null) {
    return null;
  }
  return double.tryParse(match.group(1)!.trim());
}


List<CheckpointData> _parseCheckpoints(String source) {
  final section = _extractSection(source, 'checkpoints');
  if (section == null) {
    return const [];
  }

  return RegExp(
    r'CheckpointData\(\s*position:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*size:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*respawnPosition:\s*Vector2\(([^,]+),\s*([^)]+)\)\s*,?\s*\)',
    dotAll: true,
  ).allMatches(section).map((match) {
    final position = _toVector(match.group(1), match.group(2));
    final size = _toVector(match.group(3), match.group(4));
    final respawn = _toVector(match.group(5), match.group(6));
    if (position == null || size == null || respawn == null) {
      return null;
    }
    return CheckpointData(
      position: position,
      size: size,
      respawnPosition: respawn,
    );
  }).whereType<CheckpointData>().toList();
}

List<WallData> _parseWalls(String source) {
  final section = _extractSection(source, 'walls');
  if (section == null) {
    return const [];
  }

  return RegExp(
    r'WallData\(\s*position:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*size:\s*Vector2\(([^,]+),\s*([^)]+)\)(?:,\s*variant:\s*WallSegmentVariant\.(auto|top|middle|bottom))?\s*,?\s*\)',
    dotAll: true,
  ).allMatches(section).map((match) {
    final position = _toVector(match.group(1), match.group(2));
    final size = _toVector(match.group(3), match.group(4));
    if (position == null || size == null) {
      return null;
    }
    final variant = switch (match.group(5)) {
      'top' => WallSegmentVariant.top,
      'middle' => WallSegmentVariant.middle,
      'bottom' => WallSegmentVariant.bottom,
      _ => WallSegmentVariant.auto,
    };
    return WallData(position: position, size: size, variant: variant);
  }).whereType<WallData>().toList();
}

List<MovingPlatformData> _parseMovingPlatforms(String source) {
  final section = _extractSection(source, 'movingPlatforms');
  if (section == null) {
    return const [];
  }

  return RegExp(
    r'MovingPlatformData\(\s*position:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*size:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*startPosition:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*travelDistance:\s*([^,]+),\s*speed:\s*([^,\)]+)\s*,?\s*\)',
    dotAll: true,
  ).allMatches(section).map((match) {
    final position = _toVector(match.group(1), match.group(2));
    final size = _toVector(match.group(3), match.group(4));
    final startPosition = _toVector(match.group(5), match.group(6));
    final travelDistance = double.tryParse(match.group(7)!.trim());
    final speed = double.tryParse(match.group(8)!.trim());
    if (position == null ||
        size == null ||
        startPosition == null ||
        travelDistance == null ||
        speed == null) {
      return null;
    }
    return MovingPlatformData(
      position: position,
      size: size,
      startPosition: startPosition,
      travelDistance: travelDistance,
      speed: speed,
    );
  }).whereType<MovingPlatformData>().toList();
}

List<TestPortalData> _parseTestPortals(String source) {
  final section = _extractSection(source, 'testPortals');
  if (section == null) {
    return const [];
  }

  return RegExp(
    r'TestPortalData\(\s*position:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*size:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*targetStageIndex:\s*(\d+)\s*,?\s*\)',
    dotAll: true,
  ).allMatches(section).map((match) {
    final position = _toVector(match.group(1), match.group(2));
    final size = _toVector(match.group(3), match.group(4));
    final index = int.tryParse(match.group(5)!);
    if (position == null || size == null || index == null) {
      return null;
    }
    return TestPortalData(
      position: position,
      size: size,
      targetStageIndex: index,
    );
  }).whereType<TestPortalData>().toList();
}

List<VerticalMovingPlatformData> _parseVerticalMovingPlatforms(String source) {
  final section = _extractSection(source, 'verticalMovingPlatforms');
  if (section == null) {
    return const [];
  }

  return RegExp(
    r'VerticalMovingPlatformData\(\s*position:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*size:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*startPosition:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*travelDistance:\s*([^,]+),\s*speed:\s*([^,]+),\s*startsMovingUp:\s*(true|false)\s*,?\s*\)',
    dotAll: true,
  ).allMatches(section).map((match) {
    final position = _toVector(match.group(1), match.group(2));
    final size = _toVector(match.group(3), match.group(4));
    final startPosition = _toVector(match.group(5), match.group(6));
    final travelDistance = double.tryParse(match.group(7)!.trim());
    final speed = double.tryParse(match.group(8)!.trim());
    final startsMovingUp = match.group(9) == 'true';
    if (position == null ||
        size == null ||
        startPosition == null ||
        travelDistance == null ||
        speed == null) {
      return null;
    }
    return VerticalMovingPlatformData(
      position: position,
      size: size,
      startPosition: startPosition,
      travelDistance: travelDistance,
      speed: speed,
      startsMovingUp: startsMovingUp,
    );
  }).whereType<VerticalMovingPlatformData>().toList();
}

List<DisappearingPlatformData> _parseDisappearingPlatforms(String source) {
  final section = _extractSection(source, 'disappearingPlatforms');
  if (section == null) {
    return const [];
  }

  return RegExp(
    r'DisappearingPlatformData\(\s*position:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*size:\s*Vector2\(([^,]+),\s*([^)]+)\),\s*collapseDelay:\s*([^,]+),\s*respawnDelay:\s*([^,\)]+)\s*,?\s*\)',
    dotAll: true,
  ).allMatches(section).map((match) {
    final position = _toVector(match.group(1), match.group(2));
    final size = _toVector(match.group(3), match.group(4));
    final collapseDelay = double.tryParse(match.group(5)!.trim());
    final respawnDelay = double.tryParse(match.group(6)!.trim());
    if (position == null ||
        size == null ||
        collapseDelay == null ||
        respawnDelay == null) {
      return null;
    }
    return DisappearingPlatformData(
      position: position,
      size: size,
      collapseDelay: collapseDelay,
      respawnDelay: respawnDelay,
    );
  }).whereType<DisappearingPlatformData>().toList();
}

String? _extractSection(String source, String fieldName) {
  final start = source.indexOf('$fieldName: [');
  if (start == -1) {
    return null;
  }

  final listStart = source.indexOf('[', start);
  if (listStart == -1) {
    return null;
  }

  var depth = 0;
  for (var i = listStart; i < source.length; i++) {
    final char = source[i];
    if (char == '[') {
      depth++;
    } else if (char == ']') {
      depth--;
      if (depth == 0) {
        return source.substring(listStart + 1, i);
      }
    }
  }

  return null;
}

Vector2? _toVector(String? xRaw, String? yRaw) {
  final x = double.tryParse(xRaw?.trim() ?? '');
  final y = double.tryParse(yRaw?.trim() ?? '');
  if (x == null || y == null) {
    return null;
  }
  return Vector2(x, y);
}
