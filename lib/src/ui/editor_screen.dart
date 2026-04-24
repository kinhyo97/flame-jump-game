import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../world/editor_draft_store.dart';
import '../world/levels_registry.dart';
import 'editor/editor_canvas.dart';
import 'editor/editor_constants.dart';
import 'editor/editor_draft_builder.dart';
import 'editor/editor_exporter.dart';
import 'editor/editor_importer.dart';
import 'editor/editor_panels.dart';
import 'editor/editor_point_objects.dart';
import 'editor/editor_session_data.dart';
import 'editor/editor_types.dart';
import 'editor/export_file_stub.dart'
    if (dart.library.html) 'editor/export_file_web.dart';
import 'editor/import_file_stub.dart'
    if (dart.library.html) 'editor/import_file_web.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  static const _viewportNudgeStep = 96.0;
  static const _worldWidthStep = 160.0;

  late final TransformationController _transformationController;
  late final List<PlatformSurface> _surfaces;
  late final Map<EditorTool, List<Vector2>> _pointObjects;
  late final List<CheckpointData> _checkpoints;
  late final List<WallData> _walls;
  late final List<DisappearingPlatformData> _disappearingPlatforms;
  late double _worldWidth;

  PlatformSurface? _previewSurface;
  Vector2? _previewPointObject;
  CheckpointData? _previewCheckpoint;
  WallData? _previewWall;
  DisappearingPlatformData? _previewDisappearingPlatform;
  bool _canPlacePreview = true;
  EditorTool _currentTool = EditorTool.surface;
  EditorPaletteFilter _paletteFilter = EditorPaletteFilter.all;
  final List<EditorSelection> _selectedObjects = [];
  Offset? _selectionDragStart;
  Offset? _selectionDragCurrent;
  String _loadedMapLabel = 'Draft Map';

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    final restoredSession = restoreEditorSession(EditorDraftStore.currentLevel);
    _worldWidth = restoredSession.worldWidth;
    _surfaces = restoredSession.surfaces;
    _pointObjects = {
      EditorTool.coin: restoredSession.coins,
      EditorTool.heart: restoredSession.hearts,
      EditorTool.star: restoredSession.stars,
      EditorTool.spike: restoredSession.spikes,
      EditorTool.saw: restoredSession.saws,
      EditorTool.spring: restoredSession.springs,
    };
    _checkpoints = restoredSession.checkpoints;
    _walls = restoredSession.walls;
    _disappearingPlatforms = restoredSession.disappearingPlatforms;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _persistDraft() {
    EditorDraftStore.save(
      _buildCurrentDraftLevel(),
    );
  }

  void _applySession(EditorSessionData session) {
    setState(() {
      _surfaces
        ..clear()
        ..addAll(session.surfaces);
      _replacePointObjects(EditorTool.coin, session.coins);
      _replacePointObjects(EditorTool.heart, session.hearts);
      _replacePointObjects(EditorTool.star, session.stars);
      _replacePointObjects(EditorTool.spike, session.spikes);
      _replacePointObjects(EditorTool.saw, session.saws);
      _replacePointObjects(EditorTool.spring, session.springs);
      _checkpoints
        ..clear()
        ..addAll(session.checkpoints);
      _walls
        ..clear()
        ..addAll(session.walls);
      _disappearingPlatforms
        ..clear()
        ..addAll(session.disappearingPlatforms);
      _worldWidth = session.worldWidth;
      _previewSurface = null;
      _previewPointObject = null;
      _previewCheckpoint = null;
      _previewWall = null;
      _previewDisappearingPlatform = null;
      _canPlacePreview = true;
      _selectedObjects.clear();
      _selectionDragStart = null;
      _selectionDragCurrent = null;
      _currentTool = EditorTool.cursor;
      _paletteFilter = EditorPaletteFilter.all;
    });
    _persistDraft();
  }

  void _applyNamedSession(EditorSessionData session, String label) {
    _applySession(session);
    setState(() {
      _loadedMapLabel = label;
    });
  }

  LevelData _buildCurrentDraftLevel() {
    return buildDraftLevelData(
      worldWidth: _worldWidth,
      surfaces: _surfaces,
      coins: _pointObjectList(EditorTool.coin),
      hearts: _pointObjectList(EditorTool.heart),
      stars: _pointObjectList(EditorTool.star),
      spikes: _pointObjectList(EditorTool.spike),
      saws: _pointObjectList(EditorTool.saw),
      checkpoints: _checkpoints,
      springs: _pointObjectList(EditorTool.spring),
      walls: _walls,
      disappearingPlatforms: _disappearingPlatforms,
    );
  }

  Future<void> _showExportDialog() async {
    final draftLevel = _buildCurrentDraftLevel();
    final exportCode = buildLevelDataExport(level: draftLevel);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF182334),
          title: const Text(
            'Export Map Data',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 760,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '현재 draft를 Dart 코드로 내보낼 수 있습니다.',
                  style: TextStyle(color: Color(0xFFD6E2F0)),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 420),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1726),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x2AFFFFFF)),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      exportCode,
                      style: const TextStyle(
                        color: Color(0xFFE6F0FF),
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton.tonal(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: exportCode));
                if (!mounted || !dialogContext.mounted) {
                  return;
                }
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('맵 코드가 클립보드에 복사됐습니다.')),
                );
              },
              child: const Text('Copy Code'),
            ),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                final saved = await saveExportFile(
                  filename: 'editor_export_level.dart',
                  contents: exportCode,
                );
                if (!mounted || !dialogContext.mounted) {
                  return;
                }
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      saved
                          ? '맵 코드 파일 다운로드를 시작했습니다.'
                          : '이 환경에서는 파일 다운로드를 지원하지 않아 코드 복사를 사용하면 됩니다.',
                    ),
                  ),
                );
              },
              child: const Text('Export File'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLoadDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF182334),
          title: const Text(
            'Load Round',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '등록된 레벨 파일을 에디터로 불러옵니다.',
                  style: TextStyle(color: Color(0xFFD6E2F0)),
                ),
                const SizedBox(height: 14),
                FilledButton.tonal(
                  onPressed: () {
                    _applySession(
                      restoreEditorSession(
                        buildDraftLevelData(
                          worldWidth: EditorConstants.defaultWorldWidth,
                          surfaces: const [],
                          coins: const [],
                          hearts: const [],
                          stars: const [],
                          spikes: const [],
                          saws: const [],
                          checkpoints: const [],
                          springs: const [],
                          walls: const [],
                          disappearingPlatforms: const [],
                        ),
                      ),
                    );
                    setState(() {
                      _loadedMapLabel = 'Draft Map';
                    });
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('New Empty Map'),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < gameLevels.length; i++) ...[
                  FilledButton(
                    onPressed: () {
                      _applyNamedSession(
                        restoreEditorSession(gameLevels[i]),
                        'Round ${i + 1}',
                      );
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text('Load Round ${i + 1}'),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showImportDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF182334),
          title: const Text(
            'Import Map Code',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 760,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'export한 코드나 기존 level 파일 내용을 그대로 붙여넣을 수 있습니다.',
                  style: TextStyle(color: Color(0xFFD6E2F0)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  minLines: 12,
                  maxLines: 18,
                  style: const TextStyle(
                    color: Color(0xFFE6F0FF),
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'LevelData 코드 붙여넣기...',
                    hintStyle: const TextStyle(color: Color(0x88FFFFFF)),
                    filled: true,
                    fillColor: const Color(0xFF0F1726),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton.tonal(
              onPressed: () async {
                final fileText = await pickImportFileText();
                if (fileText != null && dialogContext.mounted) {
                  controller.text = fileText;
                }
              },
              child: const Text('Open File'),
            ),
            FilledButton(
              onPressed: () {
                final parsedLevel = parseLevelDataCode(controller.text);
                if (parsedLevel == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('코드를 읽지 못했습니다. LevelData 형식을 확인해주세요.'),
                    ),
                  );
                  return;
                }

                _applySession(restoreEditorSession(parsedLevel));
                setState(() {
                  _loadedMapLabel = 'Imported Round';
                });
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('맵 코드를 불러왔습니다.')),
                );
              },
              child: const Text('Import Code'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  void _nudgeViewport({required double dx, required double dy}) {
    final next = _transformationController.value.clone();
    next.setTranslationRaw(
      next.storage[12] + dx,
      next.storage[13] + dy,
      next.storage[14],
    );
    _transformationController.value = next;
  }

  List<Vector2> _pointObjectList(EditorTool tool) {
    return _pointObjects[tool]!;
  }

  void _replacePointObjects(EditorTool tool, List<Vector2> values) {
    final objects = _pointObjectList(tool);
    objects
      ..clear()
      ..addAll(values);
  }

  WallSegmentVariant _wallVariantForTool(EditorTool tool) {
    return switch (tool) {
      EditorTool.wallTop => WallSegmentVariant.top,
      EditorTool.wallMiddle => WallSegmentVariant.middle,
      EditorTool.wallBottom => WallSegmentVariant.bottom,
      _ => WallSegmentVariant.middle,
    };
  }

  EditorObjectType _wallObjectType(WallSegmentVariant variant) {
    return switch (variant) {
      WallSegmentVariant.top => EditorObjectType.wallTop,
      WallSegmentVariant.middle => EditorObjectType.wallMiddle,
      WallSegmentVariant.bottom => EditorObjectType.wallBottom,
      WallSegmentVariant.auto => EditorObjectType.wallMiddle,
    };
  }

  void _clearPreview() {
    setState(() {
      _previewSurface = null;
      _previewPointObject = null;
      _previewCheckpoint = null;
      _previewWall = null;
      _previewDisappearingPlatform = null;
      _canPlacePreview = true;
    });
  }

  void _setTool(EditorTool tool) {
    setState(() {
      _currentTool = tool;
      _previewSurface = null;
      _previewPointObject = null;
      _previewCheckpoint = null;
      _previewWall = null;
      _previewDisappearingPlatform = null;
      _canPlacePreview = true;
      if (tool != EditorTool.cursor) {
        _selectedObjects.clear();
        _selectionDragStart = null;
        _selectionDragCurrent = null;
      }
    });
  }

  Rect? get _selectionRect {
    final start = _selectionDragStart;
    final current = _selectionDragCurrent;
    if (start == null || current == null) {
      return null;
    }

    return Rect.fromPoints(
      Offset(
        start.dx < current.dx ? start.dx : current.dx,
        start.dy < current.dy ? start.dy : current.dy,
      ),
      Offset(
        start.dx > current.dx ? start.dx : current.dx,
        start.dy > current.dy ? start.dy : current.dy,
      ),
    );
  }

  Vector2 _buildSnappedPoint(
    Offset localPosition, {
    required double width,
    required double height,
    required double snapStep,
  }) {
    final scenePoint = _transformationController.toScene(localPosition);
    final snappedX = (scenePoint.dx / snapStep).floor() * snapStep;
    final snappedY =
        ((scenePoint.dy - EditorConstants.gridYOffset) / snapStep).floor() *
            snapStep +
        EditorConstants.gridYOffset;
    final maxX = _worldWidth - width;
    final maxY = EditorConstants.worldHeight - height;

    return Vector2(
      snappedX.clamp(0.0, maxX),
      snappedY.clamp(0.0, maxY),
    );
  }

  PlatformSurface _buildSnappedSurface(Offset localPosition) {
    final scenePoint = _transformationController.toScene(localPosition);
    final snappedX =
        (scenePoint.dx / EditorConstants.tileSize).floor() *
        EditorConstants.tileSize;
    final snappedY =
        ((scenePoint.dy - EditorConstants.gridYOffset) /
                    EditorConstants.tileSize)
                .floor() *
            EditorConstants.tileSize +
        EditorConstants.gridYOffset;
    final maxX = _worldWidth - EditorConstants.newSurfaceWidth;
    final maxY = EditorConstants.worldHeight - EditorConstants.newSurfaceHeight;

    return PlatformSurface(
      position: Vector2(
        snappedX.clamp(0.0, maxX),
        snappedY.clamp(0.0, maxY),
      ),
      size: Vector2(
        EditorConstants.newSurfaceWidth,
        EditorConstants.newSurfaceHeight,
      ),
    );
  }

  Vector2 _buildSnappedPointObject(
    EditorPointObjectDefinition definition,
    Offset localPosition,
  ) {
    return _buildSnappedPoint(
      localPosition,
      width: definition.width,
      height: definition.height,
      snapStep: definition.snapStep,
    );
  }

  CheckpointData _buildCheckpoint(Offset localPosition) {
    final position = _buildSnappedPoint(
      localPosition,
      width: EditorConstants.checkpointWidth,
      height: EditorConstants.checkpointHeight,
      snapStep: EditorConstants.objectSnapStep,
    );
    final respawnPosition = Vector2(
      (position.x - 60).clamp(
        0.0,
        _worldWidth - PlayerConstants.size.x,
      ),
      (position.y + 16).clamp(
        0.0,
        EditorConstants.worldHeight - PlayerConstants.size.y,
      ),
    );

    return CheckpointData(
      position: position,
      size: Vector2(
        EditorConstants.checkpointWidth,
        EditorConstants.checkpointHeight,
      ),
      respawnPosition: respawnPosition,
    );
  }

  double get _minimumWorldWidthForContent {
    var maxRight = EditorConstants.minWorldWidth;

    for (final surface in _surfaces) {
      final right = surface.position.x + surface.size.x;
      if (right > maxRight) {
        maxRight = right;
      }
    }

    for (final definition in editorPointObjectDefinitions) {
      for (final point in _pointObjectList(definition.tool)) {
        final right = point.x + definition.width;
        if (right > maxRight) {
          maxRight = right;
        }
      }
    }

    for (final checkpoint in _checkpoints) {
      final right = checkpoint.position.x + checkpoint.size.x;
      if (right > maxRight) {
        maxRight = right;
      }
    }

    for (final wall in _walls) {
      final right = wall.position.x + wall.size.x;
      if (right > maxRight) {
        maxRight = right;
      }
    }

    for (final platform in _disappearingPlatforms) {
      final right = platform.position.x + platform.size.x;
      if (right > maxRight) {
        maxRight = right;
      }
    }

    return (maxRight + 160)
        .clamp(EditorConstants.minWorldWidth, EditorConstants.maxWorldWidth);
  }

  void _increaseWorldWidth() {
    final nextWidth = (_worldWidth + _worldWidthStep).clamp(
      _minimumWorldWidthForContent,
      EditorConstants.maxWorldWidth,
    );

    if ((nextWidth - _worldWidth).abs() < 0.1) {
      return;
    }

    setState(() {
      _worldWidth = nextWidth;
    });
    _persistDraft();
  }

  void _decreaseWorldWidth() {
    final nextWidth = (_worldWidth - _worldWidthStep).clamp(
      _minimumWorldWidthForContent,
      EditorConstants.maxWorldWidth,
    );

    if ((nextWidth - _worldWidth).abs() < 0.1) {
      return;
    }

    setState(() {
      _worldWidth = nextWidth;
    });
    _persistDraft();
  }

  WallData _buildWall(Offset localPosition) {
    final variant = _wallVariantForTool(_currentTool);
    final position = _buildSnappedPoint(
      localPosition,
      width: EditorConstants.wallWidth,
      height: EditorConstants.wallHeight,
      snapStep: EditorConstants.tileSize,
    );
    return WallData(
      position: position,
      size: Vector2(EditorConstants.wallWidth, EditorConstants.wallHeight),
      variant: variant,
    );
  }

  DisappearingPlatformData _buildDisappearingPlatform(Offset localPosition) {
    final position = _buildSnappedPoint(
      localPosition,
      width: EditorConstants.disappearingPlatformWidth,
      height: EditorConstants.disappearingPlatformHeight,
      snapStep: EditorConstants.tileSize,
    );
    return DisappearingPlatformData(
      position: position,
      size: Vector2(
        EditorConstants.disappearingPlatformWidth,
        EditorConstants.disappearingPlatformHeight,
      ),
    );
  }

  bool _canPlaceRect(Rect candidateRect, {required List<Rect> existingRects}) {
    for (final existingRect in existingRects) {
      if (candidateRect.overlaps(existingRect)) {
        return false;
      }
    }
    return true;
  }

  bool _canPlaceSurface(PlatformSurface candidate) {
    return _canPlaceRect(
      Rect.fromLTWH(
        candidate.position.x,
        candidate.position.y,
        candidate.size.x,
        candidate.size.y,
      ),
      existingRects: _surfaces
          .map(
            (surface) => Rect.fromLTWH(
              surface.position.x,
              surface.position.y,
              surface.size.x,
              surface.size.y,
            ),
          )
          .toList(),
    );
  }

  bool _canPlacePointObject(
    EditorPointObjectDefinition definition,
    Vector2 candidate,
  ) {
    return _canPlaceRect(
      Rect.fromLTWH(
        candidate.x,
        candidate.y,
        definition.width,
        definition.height,
      ),
      existingRects: _pointObjectList(definition.tool)
          .map(
            (point) => Rect.fromLTWH(
              point.x,
              point.y,
              definition.width,
              definition.height,
            ),
          )
          .toList(),
    );
  }

  bool _canPlaceCheckpoint(CheckpointData candidate) {
    return _canPlaceRect(
      Rect.fromLTWH(
        candidate.position.x,
        candidate.position.y,
        candidate.size.x,
        candidate.size.y,
      ),
      existingRects: _checkpoints
          .map(
            (checkpoint) => Rect.fromLTWH(
              checkpoint.position.x,
              checkpoint.position.y,
              checkpoint.size.x,
              checkpoint.size.y,
            ),
          )
          .toList(),
    );
  }

  bool _canPlaceWall(WallData candidate) {
    return _canPlaceRect(
      Rect.fromLTWH(
        candidate.position.x,
        candidate.position.y,
        candidate.size.x,
        candidate.size.y,
      ),
      existingRects: _walls
          .map(
            (wall) => Rect.fromLTWH(
              wall.position.x,
              wall.position.y,
              wall.size.x,
              wall.size.y,
            ),
          )
          .toList(),
    );
  }

  bool _canPlaceDisappearingPlatform(DisappearingPlatformData candidate) {
    return _canPlaceRect(
      Rect.fromLTWH(
        candidate.position.x,
        candidate.position.y,
        candidate.size.x,
        candidate.size.y,
      ),
      existingRects: _disappearingPlatforms
          .map(
            (platform) => Rect.fromLTWH(
              platform.position.x,
              platform.position.y,
              platform.size.x,
              platform.size.y,
            ),
          )
          .toList(),
    );
  }

  EditorSelection? _findObjectAt(Offset localPosition) {
    final scenePoint = _transformationController.toScene(localPosition);

    for (var i = _checkpoints.length - 1; i >= 0; i--) {
      final checkpoint = _checkpoints[i];
      final rect = Rect.fromLTWH(
        checkpoint.position.x,
        checkpoint.position.y,
        checkpoint.size.x,
        checkpoint.size.y,
      );
      if (rect.contains(scenePoint)) {
        return EditorSelection(
          type: EditorObjectType.checkpoint,
          index: i,
        );
      }
    }

    for (var i = _disappearingPlatforms.length - 1; i >= 0; i--) {
      final platform = _disappearingPlatforms[i];
      final rect = Rect.fromLTWH(
        platform.position.x,
        platform.position.y,
        platform.size.x,
        platform.size.y,
      );
      if (rect.contains(scenePoint)) {
        return EditorSelection(
          type: EditorObjectType.disappearingPlatform,
          index: i,
        );
      }
    }

    for (var i = _walls.length - 1; i >= 0; i--) {
      final wall = _walls[i];
      final rect = Rect.fromLTWH(
        wall.position.x,
        wall.position.y,
        wall.size.x,
        wall.size.y,
      );
      if (rect.contains(scenePoint)) {
        return EditorSelection(
          type: _wallObjectType(wall.variant),
          index: i,
        );
      }
    }

    for (final definition in editorPointObjectDefinitions.reversed) {
      final objects = _pointObjectList(definition.tool);
      for (var i = objects.length - 1; i >= 0; i--) {
        final point = objects[i];
        final rect = Rect.fromLTWH(
          point.x,
          point.y,
          definition.width,
          definition.height,
        );
        if (rect.contains(scenePoint)) {
          return EditorSelection(
            type: definition.objectType,
            index: i,
          );
        }
      }
    }

    for (var i = _surfaces.length - 1; i >= 0; i--) {
      final surface = _surfaces[i];
      final rect = Rect.fromLTWH(
        surface.position.x,
        surface.position.y,
        surface.size.x,
        surface.size.y,
      );
      if (rect.contains(scenePoint)) {
        return EditorSelection(
          type: EditorObjectType.surface,
          index: i,
        );
      }
    }

    return null;
  }

  void _selectObjectAt(Offset localPosition) {
    final selection = _findObjectAt(localPosition);
    setState(() {
      _selectedObjects
        ..clear()
        ..addAll(selection == null ? const [] : [selection]);
    });
  }

  List<EditorSelection> _findObjectsInRect(Rect selectionRect) {
    final selections = <EditorSelection>[];

    for (var i = 0; i < _surfaces.length; i++) {
      final surface = _surfaces[i];
      final rect = Rect.fromLTWH(
        surface.position.x,
        surface.position.y,
        surface.size.x,
        surface.size.y,
      );
      if (selectionRect.overlaps(rect)) {
        selections.add(
          EditorSelection(type: EditorObjectType.surface, index: i),
        );
      }
    }

    for (final definition in editorPointObjectDefinitions) {
      final objects = _pointObjectList(definition.tool);
      for (var i = 0; i < objects.length; i++) {
        final point = objects[i];
        final rect = Rect.fromLTWH(
          point.x,
          point.y,
          definition.width,
          definition.height,
        );
        if (selectionRect.overlaps(rect)) {
          selections.add(
            EditorSelection(type: definition.objectType, index: i),
          );
        }
      }
    }

    for (var i = 0; i < _checkpoints.length; i++) {
      final checkpoint = _checkpoints[i];
      final rect = Rect.fromLTWH(
        checkpoint.position.x,
        checkpoint.position.y,
        checkpoint.size.x,
        checkpoint.size.y,
      );
      if (selectionRect.overlaps(rect)) {
        selections.add(
          EditorSelection(type: EditorObjectType.checkpoint, index: i),
        );
      }
    }

    for (var i = 0; i < _walls.length; i++) {
      final wall = _walls[i];
      final rect = Rect.fromLTWH(
        wall.position.x,
        wall.position.y,
        wall.size.x,
        wall.size.y,
      );
      if (selectionRect.overlaps(rect)) {
        selections.add(
          EditorSelection(type: _wallObjectType(wall.variant), index: i),
        );
      }
    }

    for (var i = 0; i < _disappearingPlatforms.length; i++) {
      final platform = _disappearingPlatforms[i];
      final rect = Rect.fromLTWH(
        platform.position.x,
        platform.position.y,
        platform.size.x,
        platform.size.y,
      );
      if (selectionRect.overlaps(rect)) {
        selections.add(
          EditorSelection(
            type: EditorObjectType.disappearingPlatform,
            index: i,
          ),
        );
      }
    }

    return selections;
  }

  void _startSelectionDrag(Offset localPosition) {
    if (_currentTool != EditorTool.cursor) {
      return;
    }

    final scenePoint = _transformationController.toScene(localPosition);
    setState(() {
      _selectionDragStart = scenePoint;
      _selectionDragCurrent = scenePoint;
    });
  }

  void _updateSelectionDrag(Offset localPosition) {
    if (_currentTool != EditorTool.cursor || _selectionDragStart == null) {
      return;
    }

    final scenePoint = _transformationController.toScene(localPosition);
    setState(() {
      _selectionDragCurrent = scenePoint;
    });
  }

  void _endSelectionDrag(Offset localPosition) {
    if (_currentTool != EditorTool.cursor || _selectionDragStart == null) {
      return;
    }

    final scenePoint = _transformationController.toScene(localPosition);
    final start = _selectionDragStart!;
    final dx = (scenePoint.dx - start.dx).abs();
    final dy = (scenePoint.dy - start.dy).abs();

    if (dx < 6 && dy < 6) {
      _selectionDragStart = null;
      _selectionDragCurrent = null;
      _selectObjectAt(localPosition);
      return;
    }

    final selectionRect = Rect.fromPoints(start, scenePoint);
    final selections = _findObjectsInRect(selectionRect);

    setState(() {
      _selectedObjects
        ..clear()
        ..addAll(selections);
      _selectionDragStart = null;
      _selectionDragCurrent = null;
    });
  }

  void _deleteSelectedObject() {
    if (_selectedObjects.isEmpty) {
      return;
    }

    setState(() {
      void removeSelected<T>(
        EditorObjectType type,
        List<T> items,
      ) {
        final indexes = _selectedObjects
            .where((selection) => selection.type == type)
            .map((selection) => selection.index)
            .toList()
          ..sort((a, b) => b.compareTo(a));

        for (final index in indexes) {
          if (index >= 0 && index < items.length) {
            items.removeAt(index);
          }
        }
      }

      removeSelected(EditorObjectType.surface, _surfaces);
      for (final definition in editorPointObjectDefinitions) {
        removeSelected(definition.objectType, _pointObjectList(definition.tool));
      }
      removeSelected(EditorObjectType.checkpoint, _checkpoints);
      removeSelected(EditorObjectType.wallTop, _walls);
      removeSelected(EditorObjectType.wallMiddle, _walls);
      removeSelected(EditorObjectType.wallBottom, _walls);
      removeSelected(
        EditorObjectType.disappearingPlatform,
        _disappearingPlatforms,
      );

      _selectedObjects.clear();
    });
    _persistDraft();
  }

  void _addSurfaceAt(Offset localPosition) {
    final candidate = _buildSnappedSurface(localPosition);
    if (!_canPlaceSurface(candidate)) {
      _updatePreviewAt(localPosition);
      return;
    }

    setState(() {
      _surfaces.add(candidate);
      _previewSurface = candidate;
      _canPlacePreview = true;
    });
    _persistDraft();
  }

  void _addPointObjectAt(
    EditorPointObjectDefinition definition,
    Offset localPosition,
  ) {
    final candidate = _buildSnappedPointObject(definition, localPosition);
    if (!_canPlacePointObject(definition, candidate)) {
      _updatePreviewAt(localPosition);
      return;
    }

    setState(() {
      _pointObjectList(definition.tool).add(candidate);
      _previewPointObject = candidate;
      _canPlacePreview = true;
    });
    _persistDraft();
  }

  void _addCheckpointAt(Offset localPosition) {
    final candidate = _buildCheckpoint(localPosition);
    if (!_canPlaceCheckpoint(candidate)) {
      _updatePreviewAt(localPosition);
      return;
    }

    setState(() {
      _checkpoints.add(candidate);
      _previewCheckpoint = candidate;
      _canPlacePreview = true;
    });
    _persistDraft();
  }

  void _addWallAt(Offset localPosition) {
    final candidate = _buildWall(localPosition);
    if (!_canPlaceWall(candidate)) {
      _updatePreviewAt(localPosition);
      return;
    }

    setState(() {
      _walls.add(candidate);
      _previewWall = candidate;
      _canPlacePreview = true;
    });
    _persistDraft();
  }

  void _addDisappearingPlatformAt(Offset localPosition) {
    final candidate = _buildDisappearingPlatform(localPosition);
    if (!_canPlaceDisappearingPlatform(candidate)) {
      _updatePreviewAt(localPosition);
      return;
    }

    setState(() {
      _disappearingPlatforms.add(candidate);
      _previewDisappearingPlatform = candidate;
      _canPlacePreview = true;
    });
    _persistDraft();
  }

  void _updatePreviewAt(Offset localPosition) {
    final pointDefinition = _currentTool.pointObjectDefinition;
    if (pointDefinition != null) {
      final candidate = _buildSnappedPointObject(pointDefinition, localPosition);
      setState(() {
        _previewPointObject = candidate;
        _previewSurface = null;
        _previewCheckpoint = null;
        _previewWall = null;
        _previewDisappearingPlatform = null;
        _canPlacePreview = _canPlacePointObject(pointDefinition, candidate);
      });
      return;
    }

    switch (_currentTool) {
      case EditorTool.surface:
        final candidate = _buildSnappedSurface(localPosition);
        setState(() {
          _previewSurface = candidate;
          _previewPointObject = null;
          _previewCheckpoint = null;
          _previewWall = null;
          _previewDisappearingPlatform = null;
          _canPlacePreview = _canPlaceSurface(candidate);
        });
      case EditorTool.checkpoint:
        final candidate = _buildCheckpoint(localPosition);
        setState(() {
          _previewCheckpoint = candidate;
          _previewSurface = null;
          _previewPointObject = null;
          _previewWall = null;
          _previewDisappearingPlatform = null;
          _canPlacePreview = _canPlaceCheckpoint(candidate);
        });
      case EditorTool.wallTop:
      case EditorTool.wallMiddle:
      case EditorTool.wallBottom:
        final candidate = _buildWall(localPosition);
        setState(() {
          _previewWall = candidate;
          _previewSurface = null;
          _previewPointObject = null;
          _previewCheckpoint = null;
          _previewDisappearingPlatform = null;
          _canPlacePreview = _canPlaceWall(candidate);
        });
      case EditorTool.disappearingPlatform:
        final candidate = _buildDisappearingPlatform(localPosition);
        setState(() {
          _previewDisappearingPlatform = candidate;
          _previewSurface = null;
          _previewPointObject = null;
          _previewCheckpoint = null;
          _previewWall = null;
          _canPlacePreview = _canPlaceDisappearingPlatform(candidate);
        });
      case EditorTool.cursor:
        _clearPreview();
      case EditorTool.coin:
      case EditorTool.heart:
      case EditorTool.star:
      case EditorTool.spike:
      case EditorTool.saw:
      case EditorTool.spring:
        return;
    }
  }

  void _handleCanvasTap(Offset localPosition) {
    final pointDefinition = _currentTool.pointObjectDefinition;
    if (pointDefinition != null) {
      _addPointObjectAt(pointDefinition, localPosition);
      return;
    }

    switch (_currentTool) {
      case EditorTool.surface:
        _addSurfaceAt(localPosition);
        return;
      case EditorTool.checkpoint:
        _addCheckpointAt(localPosition);
        return;
      case EditorTool.wallTop:
      case EditorTool.wallMiddle:
      case EditorTool.wallBottom:
        _addWallAt(localPosition);
        return;
      case EditorTool.disappearingPlatform:
        _addDisappearingPlatformAt(localPosition);
        return;
      case EditorTool.cursor:
        _selectObjectAt(localPosition);
        return;
      case EditorTool.coin:
      case EditorTool.heart:
      case EditorTool.star:
      case EditorTool.spike:
      case EditorTool.saw:
      case EditorTool.spring:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1521),
      body: Focus(
        autofocus: true,
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent || event is KeyRepeatEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              _setTool(EditorTool.cursor);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.delete ||
                event.logicalKey == LogicalKeyboardKey.backspace) {
              _deleteSelectedObject();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _nudgeViewport(dx: _viewportNudgeStep, dy: 0);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _nudgeViewport(dx: -_viewportNudgeStep, dy: 0);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _nudgeViewport(dx: 0, dy: _viewportNudgeStep);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _nudgeViewport(dx: 0, dy: -_viewportNudgeStep);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                EditorTopToolbar(
                  loadedMapLabel: _loadedMapLabel,
                  worldWidth: _worldWidth.toInt(),
                  onDecreaseWidthPressed: _decreaseWorldWidth,
                  onIncreaseWidthPressed: _increaseWorldWidth,
                  onLoadPressed: _showLoadDialog,
                  onImportPressed: _showImportDialog,
                  onExportPressed: _showExportDialog,
                  onMapTestPressed: () {
                    _persistDraft();
                    Navigator.of(context).pushReplacementNamed('/map-test');
                  },
                  onPlayPressed: () {
                    _persistDraft();
                    Navigator.of(context).pushNamed('/play-custom');
                  },
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Row(
                    children: [
                      EditorToolPalette(
                        currentTool: _currentTool,
                        currentFilter: _paletteFilter,
                        onToolSelected: _setTool,
                        onFilterSelected: (filter) {
                          setState(() {
                            _paletteFilter = filter;
                          });
                        },
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: EditorCanvas(
                          transformationController: _transformationController,
                          worldWidth: _worldWidth,
                          surfaces: _surfaces,
                          pointObjects: _pointObjects,
                          checkpoints: _checkpoints,
                          walls: _walls,
                          disappearingPlatforms: _disappearingPlatforms,
                          previewSurface: _currentTool == EditorTool.surface
                              ? _previewSurface
                              : null,
                          previewPointObject:
                              _currentTool.pointObjectDefinition != null
                              ? _previewPointObject
                              : null,
                          previewCheckpoint:
                              _currentTool == EditorTool.checkpoint
                              ? _previewCheckpoint
                              : null,
                          previewWall: (_currentTool == EditorTool.wallTop ||
                                  _currentTool == EditorTool.wallMiddle ||
                                  _currentTool == EditorTool.wallBottom)
                              ? _previewWall
                              : null,
                          previewDisappearingPlatform:
                              _currentTool ==
                                      EditorTool.disappearingPlatform
                              ? _previewDisappearingPlatform
                              : null,
                          canPlacePreview: _canPlacePreview,
                          currentTool: _currentTool,
                          selectedObjects: _selectedObjects,
                          selectionRect: _selectionRect,
                          onCanvasTap: _handleCanvasTap,
                          onCanvasHover: _updatePreviewAt,
                          onCanvasExit: _clearPreview,
                          onSelectionDragStart: _startSelectionDrag,
                          onSelectionDragUpdate: _updateSelectionDrag,
                          onSelectionDragEnd: _endSelectionDrag,
                        ),
                      ),
                      const SizedBox(width: 14),
                      EditorInspectorPanel(
                        worldWidth: _worldWidth.toInt(),
                        surfaceCount: _surfaces.length,
                        coinCount: _pointObjectList(EditorTool.coin).length,
                        heartCount: _pointObjectList(EditorTool.heart).length,
                        starCount: _pointObjectList(EditorTool.star).length,
                        spikeCount: _pointObjectList(EditorTool.spike).length,
                        sawCount: _pointObjectList(EditorTool.saw).length,
                        checkpointCount: _checkpoints.length,
                        springCount: _pointObjectList(EditorTool.spring).length,
                        wallCount: _walls.length,
                        disappearingPlatformCount:
                            _disappearingPlatforms.length,
                        currentTool: _currentTool,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
