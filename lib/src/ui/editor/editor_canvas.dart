import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/constants.dart';
import '../../world/level_models.dart';
import '../../world/platform_surface.dart';
import 'editor_constants.dart';
import 'editor_object_widgets.dart';
import 'editor_point_objects.dart';
import 'editor_types.dart';
import 'editor_widgets.dart';

class EditorCanvas extends StatelessWidget {
  const EditorCanvas({
    super.key,
    required this.transformationController,
    required this.worldWidth,
    required this.surfaces,
    required this.pointObjects,
    required this.checkpoints,
    required this.walls,
    required this.disappearingPlatforms,
    required this.previewSurface,
    required this.previewPointObject,
    required this.previewCheckpoint,
    required this.previewWall,
    required this.previewDisappearingPlatform,
    required this.canPlacePreview,
    required this.currentTool,
    required this.selectedObjects,
    required this.selectionRect,
    required this.onCanvasTap,
    required this.onCanvasHover,
    required this.onCanvasExit,
    required this.onSelectionDragStart,
    required this.onSelectionDragUpdate,
    required this.onSelectionDragEnd,
  });

  final TransformationController transformationController;
  final double worldWidth;
  final List<PlatformSurface> surfaces;
  final Map<EditorTool, List<Vector2>> pointObjects;
  final List<CheckpointData> checkpoints;
  final List<WallData> walls;
  final List<DisappearingPlatformData> disappearingPlatforms;
  final PlatformSurface? previewSurface;
  final Vector2? previewPointObject;
  final CheckpointData? previewCheckpoint;
  final WallData? previewWall;
  final DisappearingPlatformData? previewDisappearingPlatform;
  final bool canPlacePreview;
  final EditorTool currentTool;
  final List<EditorSelection> selectedObjects;
  final Rect? selectionRect;
  final ValueChanged<Offset> onCanvasTap;
  final ValueChanged<Offset> onCanvasHover;
  final VoidCallback onCanvasExit;
  final ValueChanged<Offset> onSelectionDragStart;
  final ValueChanged<Offset> onSelectionDragUpdate;
  final ValueChanged<Offset> onSelectionDragEnd;

  @override
  Widget build(BuildContext context) {
    final guidePosition = _guidePosition;

    return EditorPanel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            MouseRegion(
              cursor: currentTool == EditorTool.cursor
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.precise,
              onHover: (event) {
                if (currentTool == EditorTool.cursor) {
                  return;
                }
                onCanvasHover(event.localPosition);
              },
              onExit: (_) => onCanvasExit(),
              child: Listener(
                onPointerDown: (event) {
                  if (currentTool == EditorTool.cursor) {
                    onSelectionDragStart(event.localPosition);
                  }
                },
                onPointerMove: (event) {
                  if (currentTool == EditorTool.cursor) {
                    onSelectionDragUpdate(event.localPosition);
                  }
                },
                onPointerUp: (event) {
                  if (currentTool == EditorTool.cursor) {
                    onSelectionDragEnd(event.localPosition);
                  }
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: currentTool == EditorTool.cursor
                      ? null
                      : (details) => onCanvasTap(details.localPosition),
                  child: InteractiveViewer(
                    transformationController: transformationController,
                    boundaryMargin: const EdgeInsets.all(120),
                    minScale: 0.28,
                    maxScale: 2.4,
                    panEnabled: false,
                    constrained: false,
                    child: SizedBox(
                      width: worldWidth,
                      height: EditorConstants.worldHeight,
                      child: Stack(
                        children: [
                      Container(
                        color: const Color(0xFF9FC5E8),
                        child: const CustomPaint(
                          painter: GridPainter(
                            minorStep: EditorConstants.tileSize,
                            majorStep: EditorConstants.tileSize * 4,
                            originY: EditorConstants.gridYOffset,
                          ),
                          child: SizedBox.expand(),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top:
                            EditorConstants.worldHeight -
                            GameConstants.floorHeight,
                        bottom: 0,
                        child: Container(color: const Color(0xFFE7A06C)),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top:
                            EditorConstants.worldHeight -
                            GameConstants.floorHeight,
                        child: Container(
                          height: 8,
                          color: const Color(0xFF2FC46B),
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 24,
                        child: CanvasBadge(
                          'World ${worldWidth.toInt()} x ${EditorConstants.worldHeight.toInt()}',
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 64,
                        child: CanvasBadge(_toolHint(currentTool)),
                      ),
                      if (guidePosition != null) ...[
                        Positioned(
                          left: guidePosition.x,
                          top: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: Container(
                              width: 2,
                              color: const Color(0xAA39D98A),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: guidePosition.y,
                          child: IgnorePointer(
                            child: Container(
                              height: 2,
                              color: const Color(0xAA39D98A),
                            ),
                          ),
                        ),
                        Positioned(
                          left: guidePosition.x + 8,
                          top: guidePosition.y + 8,
                          child: IgnorePointer(
                            child: CanvasBadge(
                              '${guidePosition.x.toInt()}, ${guidePosition.y.toInt()}',
                            ),
                          ),
                        ),
                      ],
                      ...surfaces.asMap().entries.map(
                        (entry) => _buildSurface(
                          entry.value,
                          index: entry.key,
                          isPreview: false,
                        ),
                      ),
                      ...editorPointObjectDefinitions.expand((definition) {
                        final objects = pointObjects[definition.tool] ?? const <Vector2>[];
                        return objects.asMap().entries.map(
                          (entry) => _buildPointObject(
                            definition,
                            entry.value,
                            index: entry.key,
                            isPreview: false,
                          ),
                        );
                      }),
                      ...checkpoints.asMap().entries.map(
                        (entry) => _buildCheckpoint(
                          entry.value,
                          index: entry.key,
                          isPreview: false,
                        ),
                      ),
                      ...walls.asMap().entries.map(
                        (entry) => _buildWall(
                          entry.value,
                          index: entry.key,
                          isPreview: false,
                        ),
                      ),
                      ...disappearingPlatforms.asMap().entries.map(
                        (entry) => _buildDisappearingPlatform(
                          entry.value,
                          index: entry.key,
                          isPreview: false,
                        ),
                      ),
                      if (previewSurface != null)
                        _buildSurface(
                          previewSurface!,
                          isPreview: true,
                          canPlace: canPlacePreview,
                        ),
                      if (previewPointObject != null &&
                          currentTool.pointObjectDefinition != null)
                        _buildPointObject(
                          currentTool.pointObjectDefinition!,
                          previewPointObject!,
                          isPreview: true,
                          canPlace: canPlacePreview,
                        ),
                      if (previewCheckpoint != null)
                        _buildCheckpoint(
                          previewCheckpoint!,
                          isPreview: true,
                          canPlace: canPlacePreview,
                        ),
                      if (previewWall != null)
                        _buildWall(
                          previewWall!,
                          isPreview: true,
                          canPlace: canPlacePreview,
                        ),
                      if (previewDisappearingPlatform != null)
                        _buildDisappearingPlatform(
                          previewDisappearingPlatform!,
                          isPreview: true,
                          canPlace: canPlacePreview,
                        ),
                      if (selectionRect != null)
                        Positioned(
                          left: selectionRect!.left,
                          top: selectionRect!.top,
                          child: IgnorePointer(
                            child: Container(
                              width: selectionRect!.width,
                              height: selectionRect!.height,
                              decoration: BoxDecoration(
                                color: const Color(0x2239D98A),
                                border: Border.all(
                                  color: const Color(0xFF39D98A),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _toolHint(EditorTool tool) {
    final pointDefinition = tool.pointObjectDefinition;
    if (pointDefinition != null) {
      return '${pointDefinition.label} preview uses ${pointDefinition.snapStep.toInt()}px snap';
    }

    return switch (tool) {
      EditorTool.checkpoint => 'Checkpoint preview uses 4px snap',
      EditorTool.wallTop => 'Wall top preview uses 32px snap',
      EditorTool.wallMiddle => 'Wall middle preview uses 32px snap',
      EditorTool.wallBottom => 'Wall bottom preview uses 32px snap',
      EditorTool.disappearingPlatform => 'Breakable platform uses 32px snap',
      _ => 'Esc returns to cursor mode',
    };
  }

  Vector2? get _guidePosition {
    if (previewSurface != null) {
      return Vector2(
        previewSurface!.position.x + (previewSurface!.size.x / 2),
        previewSurface!.position.y + (previewSurface!.size.y / 2),
      );
    }
    if (previewPointObject != null && currentTool.pointObjectDefinition != null) {
      final definition = currentTool.pointObjectDefinition!;
      return Vector2(
        previewPointObject!.x + (definition.width / 2),
        previewPointObject!.y + (definition.height / 2),
      );
    }
    if (previewCheckpoint != null) {
      return Vector2(
        previewCheckpoint!.position.x + (previewCheckpoint!.size.x / 2),
        previewCheckpoint!.position.y + (previewCheckpoint!.size.y / 2),
      );
    }
    if (previewWall != null) {
      return Vector2(
        previewWall!.position.x + (previewWall!.size.x / 2),
        previewWall!.position.y + (previewWall!.size.y / 2),
      );
    }
    if (previewDisappearingPlatform != null) {
      return Vector2(
        previewDisappearingPlatform!.position.x +
            (previewDisappearingPlatform!.size.x / 2),
        previewDisappearingPlatform!.position.y +
            (previewDisappearingPlatform!.size.y / 2),
      );
    }
    return null;
  }

  bool _isSelected(EditorObjectType type, int index) {
    for (final selected in selectedObjects) {
      if (selected.type == type && selected.index == index) {
        return true;
      }
    }
    return false;
  }

  Widget _buildSurface(
    PlatformSurface surface, {
    int? index,
    required bool isPreview,
    bool canPlace = true,
  }) {
    return Positioned(
      left: surface.position.x,
      top: surface.position.y - 4,
      child: MockSurface(
        width: surface.size.x,
        label: isPreview
            ? canPlace
                ? 'place ${surface.position.x.toInt()}, ${surface.position.y.toInt()}'
                : 'blocked ${surface.position.x.toInt()}, ${surface.position.y.toInt()}'
            : 'surface ${surface.position.x.toInt()}, ${surface.position.y.toInt()}',
        isPreview: isPreview,
        canPlace: canPlace,
        isSelected:
            !isPreview &&
            index != null &&
            _isSelected(EditorObjectType.surface, index),
      ),
    );
  }

  Widget _buildPointObject(
    EditorPointObjectDefinition definition,
    Vector2 point, {
    int? index,
    required bool isPreview,
    bool canPlace = true,
  }) {
    if (definition.usesCoinWidget) {
      return Positioned(
        left: point.x,
        top: point.y,
        child: MockCoin(
          label: isPreview
              ? canPlace
                  ? 'place ${definition.label.toLowerCase()}'
                  : 'blocked ${definition.label.toLowerCase()}'
              : definition.label.toLowerCase(),
          isPreview: isPreview,
          canPlace: canPlace,
          isSelected:
              !isPreview &&
              index != null &&
              _isSelected(definition.objectType, index),
        ),
      );
    }

    return Positioned(
      left: point.x,
      top: point.y,
      child: MockSpriteObject(
        assetPath: definition.assetPath!,
        width: definition.width,
        height: definition.height,
        label: isPreview
            ? canPlace
                ? 'place ${definition.label.toLowerCase()}'
                : 'blocked ${definition.label.toLowerCase()}'
            : definition.label.toLowerCase(),
        isPreview: isPreview,
        canPlace: canPlace,
        isSelected:
            !isPreview &&
            index != null &&
            _isSelected(definition.objectType, index),
      ),
    );
  }

  Widget _buildCheckpoint(
    CheckpointData checkpoint, {
    int? index,
    required bool isPreview,
    bool canPlace = true,
  }) {
    return Positioned(
      left: checkpoint.position.x,
      top: checkpoint.position.y,
      child: MockSpriteObject(
        assetPath: 'assets/images/${ImageAssets.checkpointInactive}',
        width: checkpoint.size.x,
        height: checkpoint.size.y,
        label: isPreview
            ? canPlace
                ? 'place checkpoint'
                : 'blocked checkpoint'
            : 'checkpoint',
        isPreview: isPreview,
        canPlace: canPlace,
        isSelected:
            !isPreview &&
            index != null &&
            _isSelected(EditorObjectType.checkpoint, index),
      ),
    );
  }

  Widget _buildWall(
    WallData wall, {
    int? index,
    required bool isPreview,
    bool canPlace = true,
  }) {
    return Positioned(
      left: wall.position.x,
      top: wall.position.y,
      child: MockWall(
        width: wall.size.x,
        height: wall.size.y,
        variant: wall.variant,
        label: isPreview
            ? canPlace
                ? 'place ${_wallLabel(wall.variant)}'
                : 'blocked ${_wallLabel(wall.variant)}'
            : _wallLabel(wall.variant),
        isPreview: isPreview,
        canPlace: canPlace,
        isSelected:
            !isPreview &&
            index != null &&
            _isSelected(_wallObjectType(wall.variant), index),
      ),
    );
  }

  Widget _buildDisappearingPlatform(
    DisappearingPlatformData platform, {
    int? index,
    required bool isPreview,
    bool canPlace = true,
  }) {
    return Positioned(
      left: platform.position.x,
      top: platform.position.y - 4,
      child: MockSpriteObject(
        assetPath: 'assets/images/${ImageAssets.movingPlatform}',
        width: platform.size.x,
        height: platform.size.y + 4,
        fit: BoxFit.fill,
        label: isPreview
            ? canPlace
                ? 'place break'
                : 'blocked break'
            : 'break',
        isPreview: isPreview,
        canPlace: canPlace,
        isSelected:
            !isPreview &&
            index != null &&
            _isSelected(EditorObjectType.disappearingPlatform, index),
      ),
    );
  }

}

EditorObjectType _wallObjectType(WallSegmentVariant variant) {
  return switch (variant) {
    WallSegmentVariant.top => EditorObjectType.wallTop,
    WallSegmentVariant.middle => EditorObjectType.wallMiddle,
    WallSegmentVariant.bottom => EditorObjectType.wallBottom,
    WallSegmentVariant.auto => EditorObjectType.wallMiddle,
  };
}

String _wallLabel(WallSegmentVariant variant) {
  return switch (variant) {
    WallSegmentVariant.top => 'wall top',
    WallSegmentVariant.middle => 'wall mid',
    WallSegmentVariant.bottom => 'wall bottom',
    WallSegmentVariant.auto => 'wall',
  };
}
