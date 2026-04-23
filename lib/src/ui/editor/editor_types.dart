enum EditorTool {
  cursor,
  surface,
  coin,
  heart,
  star,
  spike,
  saw,
  checkpoint,
  spring,
  wallTop,
  wallMiddle,
  wallBottom,
  disappearingPlatform,
}

enum EditorPaletteFilter {
  all,
  terrain,
  pickups,
  hazards,
  interaction,
}

enum EditorObjectType {
  surface,
  coin,
  heart,
  star,
  spike,
  saw,
  checkpoint,
  spring,
  wallTop,
  wallMiddle,
  wallBottom,
  disappearingPlatform,
}

class EditorSelection {
  const EditorSelection({
    required this.type,
    required this.index,
  });

  final EditorObjectType type;
  final int index;
}
