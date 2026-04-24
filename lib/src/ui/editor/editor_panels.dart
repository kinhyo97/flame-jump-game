import 'package:flutter/material.dart';

import 'editor_point_objects.dart';
import 'editor_types.dart';
import 'editor_widgets.dart';

class EditorTopToolbar extends StatelessWidget {
  const EditorTopToolbar({
    super.key,
    required this.loadedMapLabel,
    required this.worldWidth,
    required this.onDecreaseWidthPressed,
    required this.onIncreaseWidthPressed,
    required this.onLoadPressed,
    required this.onMapTestPressed,
    required this.onPlayPressed,
    required this.onExportPressed,
    required this.onImportPressed,
  });

  final String loadedMapLabel;
  final int worldWidth;
  final VoidCallback onDecreaseWidthPressed;
  final VoidCallback onIncreaseWidthPressed;
  final VoidCallback onLoadPressed;
  final VoidCallback onMapTestPressed;
  final VoidCallback onPlayPressed;
  final VoidCallback onExportPressed;
  final VoidCallback onImportPressed;

  @override
  Widget build(BuildContext context) {
    return EditorPanel(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Map Editor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 16),
            ToolbarChip(label: loadedMapLabel, active: true),
            const SizedBox(width: 8),
            ToolbarChip(label: 'Width $worldWidth'),
            const SizedBox(width: 8),
            ToolbarButton(label: '- Width', onPressed: onDecreaseWidthPressed),
            const SizedBox(width: 8),
            ToolbarButton(label: '+ Width', onPressed: onIncreaseWidthPressed),
            const SizedBox(width: 24),
            ToolbarButton(label: 'Load Round', onPressed: onLoadPressed),
            const SizedBox(width: 10),
            ToolbarButton(label: 'Import', onPressed: onImportPressed),
            const SizedBox(width: 10),
            ToolbarButton(label: 'Export', onPressed: onExportPressed),
            const SizedBox(width: 10),
            ToolbarButton(label: 'Map Test', onPressed: onMapTestPressed),
            const SizedBox(width: 10),
            ToolbarButton(
              label: 'Play',
              highlighted: true,
              onPressed: onPlayPressed,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class EditorToolPalette extends StatelessWidget {
  const EditorToolPalette({
    super.key,
    required this.currentTool,
    required this.currentFilter,
    required this.onToolSelected,
    required this.onFilterSelected,
  });

  final EditorTool currentTool;
  final EditorPaletteFilter currentFilter;
  final ValueChanged<EditorTool> onToolSelected;
  final ValueChanged<EditorPaletteFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final currentPointObject = currentTool.pointObjectDefinition;
    final visiblePointObjects = editorPointObjectDefinitions
        .where((definition) => _matchesFilter(definition.category))
        .toList();

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 220,
        child: EditorPanel(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const PanelTitle('Palette'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: EditorPaletteFilter.values
                    .map(
                      (filter) => PaletteFilterChip(
                        label: _filterLabel(filter),
                        active: currentFilter == filter,
                        onTap: () => onFilterSelected(filter),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              if (_matchesFilter(EditorPaletteFilter.terrain))
              PaletteItem(
                label: 'Surface',
                active: currentTool == EditorTool.surface,
                onTap: () => onToolSelected(EditorTool.surface),
              ),
              ...visiblePointObjects.map(
                (definition) => PaletteItem(
                  label: definition.label,
                  active: currentTool == definition.tool,
                  onTap: () => onToolSelected(definition.tool),
                ),
              ),
              if (_matchesFilter(EditorPaletteFilter.interaction))
              PaletteItem(
                label: 'Checkpoint',
                active: currentTool == EditorTool.checkpoint,
                onTap: () => onToolSelected(EditorTool.checkpoint),
              ),
              if (_matchesFilter(EditorPaletteFilter.terrain))
              PaletteItem(
                label: 'Wall Top',
                active: currentTool == EditorTool.wallTop,
                onTap: () => onToolSelected(EditorTool.wallTop),
              ),
              if (_matchesFilter(EditorPaletteFilter.terrain))
              PaletteItem(
                label: 'Wall Mid',
                active: currentTool == EditorTool.wallMiddle,
                onTap: () => onToolSelected(EditorTool.wallMiddle),
              ),
              if (_matchesFilter(EditorPaletteFilter.terrain))
              PaletteItem(
                label: 'Wall Bottom',
                active: currentTool == EditorTool.wallBottom,
                onTap: () => onToolSelected(EditorTool.wallBottom),
              ),
              if (_matchesFilter(EditorPaletteFilter.terrain))
              PaletteItem(
                label: 'Break Platform',
                active: currentTool == EditorTool.disappearingPlatform,
                onTap: () => onToolSelected(EditorTool.disappearingPlatform),
              ),
              const SizedBox(height: 12),
              const SectionLabel('How To Use'),
              const SizedBox(height: 10),
              const MiniAction(label: '1. Pan / zoom the canvas'),
              const SizedBox(height: 8),
              MiniAction(
                label: currentTool == EditorTool.surface
                    ? '2. Click where platform should start'
                    : currentPointObject != null
                    ? currentPointObject.placementHint
                    : currentTool == EditorTool.checkpoint
                    ? '2. Click where checkpoint flag should appear'
                    : currentTool == EditorTool.wallTop
                    ? '2. Click where top wall should appear'
                    : currentTool == EditorTool.wallMiddle
                    ? '2. Click where middle wall should appear'
                    : currentTool == EditorTool.wallBottom
                    ? '2. Click where bottom wall should appear'
                    : currentTool == EditorTool.disappearingPlatform
                    ? '2. Click where break platform should appear'
                    : '2. Pick a tool to place objects',
              ),
              const SizedBox(height: 8),
              const MiniAction(label: '3. Press Esc to return to cursor'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _matchesFilter(EditorPaletteFilter category) {
    return currentFilter == EditorPaletteFilter.all || currentFilter == category;
  }
}

class EditorInspectorPanel extends StatelessWidget {
  const EditorInspectorPanel({
    super.key,
    required this.worldWidth,
    required this.surfaceCount,
    required this.coinCount,
    required this.heartCount,
    required this.starCount,
    required this.spikeCount,
    required this.sawCount,
    required this.checkpointCount,
    required this.springCount,
    required this.wallCount,
    required this.disappearingPlatformCount,
    required this.currentTool,
  });

  final int worldWidth;
  final int surfaceCount;
  final int coinCount;
  final int heartCount;
  final int starCount;
  final int spikeCount;
  final int sawCount;
  final int checkpointCount;
  final int springCount;
  final int wallCount;
  final int disappearingPlatformCount;
  final EditorTool currentTool;

  @override
  Widget build(BuildContext context) {
    final pointObjectCounts = {
      'coin count': coinCount,
      'heart count': heartCount,
      'star count': starCount,
      'spike count': spikeCount,
      'saw count': sawCount,
      'spring count': springCount,
    };

    return SizedBox(
      width: 260,
      child: EditorPanel(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelTitle('Inspector'),
              const SizedBox(height: 12),
              const SectionLabel('Canvas Units'),
              const SizedBox(height: 10),
              InfoCard(
                title: 'World Space',
                rows: [
                  'width: $worldWidth',
                  'height: 720',
                  'tile step: 32',
                  'floor height: 96',
                ],
              ),
              const SizedBox(height: 14),
              const SectionLabel('Current Tool'),
              const SizedBox(height: 10),
              const InfoCard(
                title: 'Surface Tool',
                rows: [
                  'places 128 x 28 platform',
                  'snaps start point to 32px grid',
                  'uses real world coordinates',
                ],
              ),
              const SizedBox(height: 14),
              ...editorPointObjectDefinitions.expand((definition) => [
                InfoCard(
                  title: '${definition.label} Tool',
                  rows: [
                    'places ${definition.width.toInt()} x ${definition.height.toInt()} ${definition.label.toLowerCase()}',
                    '${definition.snapStep.toInt()}px snap placement',
                    definition.tool == EditorTool.coin
                        ? 'uses original in-game hitbox'
                        : definition.tool == EditorTool.heart
                        ? 'heals one life in-game'
                        : 'uses sprite placement preview',
                  ],
                ),
                const SizedBox(height: 14),
              ]),
              const InfoCard(
                title: 'Hazards & Objects',
                rows: [
                  'spike: 32 x 30',
                  'saw: 34 x 34',
                  'checkpoint: 24 x 64',
                  'spring: 32 x 32',
                  'wall segment: 32 x 32',
                  'break platform: 96 x 28',
                ],
              ),
              const SizedBox(height: 14),
              const SectionLabel('Session'),
              const SizedBox(height: 10),
              InfoCard(
                title: 'Current Draft',
                rows: [
                  'base level: empty canvas',
                  'surface count: $surfaceCount',
                  ...pointObjectCounts.entries.map(
                    (entry) => '${entry.key}: ${entry.value}',
                  ),
                  'checkpoint count: $checkpointCount',
                  'wall count: $wallCount',
                  'break platform count: $disappearingPlatformCount',
                  'mode: ${_toolLabel(currentTool).toLowerCase()}',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _toolLabel(EditorTool tool) {
  final pointObject = tool.pointObjectDefinition;
  if (pointObject != null) {
    return '${pointObject.label} Tool';
  }

  return switch (tool) {
    EditorTool.surface => 'Surface Tool',
    EditorTool.checkpoint => 'Checkpoint Tool',
    EditorTool.wallTop => 'Wall Top Tool',
    EditorTool.wallMiddle => 'Wall Mid Tool',
    EditorTool.wallBottom => 'Wall Bottom Tool',
    EditorTool.disappearingPlatform => 'Break Platform Tool',
    EditorTool.cursor => 'Cursor',
    _ => 'Cursor',
  };
}

String _filterLabel(EditorPaletteFilter filter) {
  return switch (filter) {
    EditorPaletteFilter.all => 'All',
    EditorPaletteFilter.terrain => 'Terrain',
    EditorPaletteFilter.pickups => 'Pickups',
    EditorPaletteFilter.hazards => 'Hazards',
    EditorPaletteFilter.interaction => 'Interaction',
  };
}
