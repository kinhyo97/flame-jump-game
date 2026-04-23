import 'package:flame/components.dart';

class PlatformSurface {
  const PlatformSurface({required this.position, required this.size});

  final Vector2 position;
  final Vector2 size;

  double get left => position.x;
  double get right => position.x + size.x;
  double get top => position.y;
  double get bottom => position.y + size.y;
}
