import '../../core/assets.dart';
import 'editor_constants.dart';
import 'editor_types.dart';

class EditorPointObjectDefinition {
  const EditorPointObjectDefinition({
    required this.tool,
    required this.objectType,
    required this.category,
    required this.label,
    required this.paletteSubtitle,
    required this.placementHint,
    required this.width,
    required this.height,
    required this.snapStep,
    this.assetPath,
    this.usesCoinWidget = false,
  });

  final EditorTool tool;
  final EditorObjectType objectType;
  final EditorPaletteFilter category;
  final String label;
  final String paletteSubtitle;
  final String placementHint;
  final double width;
  final double height;
  final double snapStep;
  final String? assetPath;
  final bool usesCoinWidget;
}

const editorPointObjectDefinitions = <EditorPointObjectDefinition>[
  EditorPointObjectDefinition(
    tool: EditorTool.coin,
    objectType: EditorObjectType.coin,
    category: EditorPaletteFilter.pickups,
    label: 'Coin',
    paletteSubtitle: '4px fine placement, original pickup area',
    placementHint: '2. Click where coin should appear',
    width: EditorConstants.coinSize,
    height: EditorConstants.coinSize,
    snapStep: EditorConstants.coinSnapStep,
    usesCoinWidget: true,
  ),
  EditorPointObjectDefinition(
    tool: EditorTool.heart,
    objectType: EditorObjectType.heart,
    category: EditorPaletteFilter.pickups,
    label: 'Heart',
    paletteSubtitle: '4px placement, 28 x 28 heal pickup',
    placementHint: '2. Click where heart should appear',
    width: EditorConstants.heartSize,
    height: EditorConstants.heartSize,
    snapStep: EditorConstants.objectSnapStep,
    assetPath: 'assets/images/${ImageAssets.heartPickup}',
  ),
  EditorPointObjectDefinition(
    tool: EditorTool.star,
    objectType: EditorObjectType.star,
    category: EditorPaletteFilter.pickups,
    label: 'Star',
    paletteSubtitle: '4px placement, 30 x 30 invincibility pickup',
    placementHint: '2. Click where star should appear',
    width: EditorConstants.starSize,
    height: EditorConstants.starSize,
    snapStep: EditorConstants.objectSnapStep,
    assetPath: 'assets/images/${ImageAssets.starPickup}',
  ),
  EditorPointObjectDefinition(
    tool: EditorTool.spike,
    objectType: EditorObjectType.spike,
    category: EditorPaletteFilter.hazards,
    label: 'Spike',
    paletteSubtitle: '4px hazard placement, 32 x 30 sprite',
    placementHint: '2. Click where spike should appear',
    width: EditorConstants.spikeWidth,
    height: EditorConstants.spikeHeight,
    snapStep: EditorConstants.objectSnapStep,
    assetPath: 'assets/images/${ImageAssets.spikes}',
  ),
  EditorPointObjectDefinition(
    tool: EditorTool.saw,
    objectType: EditorObjectType.saw,
    category: EditorPaletteFilter.hazards,
    label: 'Saw',
    paletteSubtitle: '4px hazard placement, 34 x 34 sprite',
    placementHint: '2. Click where saw should appear',
    width: EditorConstants.sawSize,
    height: EditorConstants.sawSize,
    snapStep: EditorConstants.objectSnapStep,
    assetPath: 'assets/images/${ImageAssets.saw}',
  ),
  EditorPointObjectDefinition(
    tool: EditorTool.spring,
    objectType: EditorObjectType.spring,
    category: EditorPaletteFilter.interaction,
    label: 'Spring',
    paletteSubtitle: '4px placement, 32 x 32 sprite',
    placementHint: '2. Click where spring should appear',
    width: EditorConstants.springSize,
    height: EditorConstants.springSize,
    snapStep: EditorConstants.objectSnapStep,
    assetPath: 'assets/images/${ImageAssets.springIdle}',
  ),
];

extension EditorToolPointObjectExtension on EditorTool {
  EditorPointObjectDefinition? get pointObjectDefinition {
    for (final definition in editorPointObjectDefinitions) {
      if (definition.tool == this) {
        return definition;
      }
    }
    return null;
  }
}
