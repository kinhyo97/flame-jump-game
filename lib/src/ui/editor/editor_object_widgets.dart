import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../world/level_models.dart';

class MockSurface extends StatelessWidget {
  const MockSurface({
    super.key,
    required this.width,
    required this.label,
    this.isPreview = false,
    this.canPlace = true,
    this.isSelected = false,
  });

  final double width;
  final String label;
  final bool isPreview;
  final bool canPlace;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const selectedOutline = Color(0xFF39D98A);
    const selectedGlow = Color(0x6639D98A);
    final bodyColor = isPreview
        ? (canPlace ? const Color(0x88E19C6E) : const Color(0x99E57373))
        : const Color(0xFFE19C6E);
    final grassColor = isPreview
        ? (canPlace ? const Color(0xAA2FC46B) : const Color(0xCCEF5350))
        : const Color(0xFF2FC46B);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: width,
          height: 32,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 4,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: bodyColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? selectedOutline
                          : const Color(0x993C2E2A),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: selectedGlow,
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: grassColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: -26,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1D3048),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  const GridPainter({
    required this.minorStep,
    required this.majorStep,
    this.originX = 0,
    this.originY = 0,
  });

  final double minorStep;
  final double majorStep;
  final double originX;
  final double originY;

  @override
  void paint(Canvas canvas, Size size) {
    final minorPaint = Paint()
      ..color = const Color(0x10FFFFFF)
      ..strokeWidth = 1;
    final majorPaint = Paint()
      ..color = const Color(0x20FFFFFF)
      ..strokeWidth = 1.2;

    for (double x = originX; x <= size.width; x += minorStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorPaint);
    }
    for (double y = originY; y <= size.height; y += minorStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorPaint);
    }
    for (double x = originX; x <= size.width; x += majorStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
    }
    for (double y = originY; y <= size.height; y += majorStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MockSpriteObject extends StatelessWidget {
  const MockSpriteObject({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
    required this.label,
    this.fit = BoxFit.contain,
    this.isPreview = false,
    this.canPlace = true,
    this.isSelected = false,
  });

  final String assetPath;
  final double width;
  final double height;
  final String label;
  final BoxFit fit;
  final bool isPreview;
  final bool canPlace;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const selectedOutline = Color(0xFF39D98A);
    const selectedGlow = Color(0x6639D98A);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: selectedOutline, width: 2)
                : null,
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: selectedGlow,
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: isPreview ? 0.72 : 1,
            child: ColorFiltered(
              colorFilter: canPlace
                  ? const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.dst,
                    )
                  : const ColorFilter.mode(
                      Color(0xCCEF5350),
                      BlendMode.modulate,
                    ),
              child: Image.asset(assetPath, fit: fit),
            ),
          ),
        ),
        Positioned(
          left: -4,
          top: -22,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1D3048),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class MockCoin extends StatelessWidget {
  const MockCoin({
    super.key,
    required this.label,
    this.isPreview = false,
    this.canPlace = true,
    this.isSelected = false,
  });

  final String label;
  final bool isPreview;
  final bool canPlace;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const selectedOutline = Color(0xFF39D98A);
    const selectedGlow = Color(0x6639D98A);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: selectedOutline, width: 2)
                : null,
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: selectedGlow,
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: isPreview ? 0.7 : 1,
            child: ColorFiltered(
              colorFilter: canPlace
                  ? const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.dst,
                    )
                  : const ColorFilter.mode(
                      Color(0xCCEF5350),
                      BlendMode.modulate,
                    ),
              child: Image.asset(
                'assets/images/${ImageAssets.coinGold}',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          left: -6,
          top: -22,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1D3048),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class MockWall extends StatelessWidget {
  const MockWall({
    super.key,
    required this.width,
    required this.height,
    required this.label,
    this.variant = WallSegmentVariant.auto,
    this.isPreview = false,
    this.canPlace = true,
    this.isSelected = false,
  });

  final double width;
  final double height;
  final String label;
  final WallSegmentVariant variant;
  final bool isPreview;
  final bool canPlace;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const selectedOutline = Color(0xFF39D98A);
    const selectedGlow = Color(0x6639D98A);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: selectedOutline, width: 2)
                : null,
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: selectedGlow,
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: isPreview ? 0.72 : 1,
            child: ColorFiltered(
              colorFilter: canPlace
                  ? const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.dst,
                    )
                  : const ColorFilter.mode(
                      Color(0xCCEF5350),
                      BlendMode.modulate,
                    ),
              child: Column(
                children: [
                  if (variant == WallSegmentVariant.auto) ...[
                    Image.asset(
                      'assets/images/${ImageAssets.terrainStoneVerticalTop}',
                      width: width,
                      height: width,
                      fit: BoxFit.fill,
                    ),
                    Expanded(
                      child: Image.asset(
                        'assets/images/${ImageAssets.terrainStoneVerticalMiddle}',
                        width: width,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Image.asset(
                      'assets/images/${ImageAssets.terrainStoneVerticalBottom}',
                      width: width,
                      height: width,
                      fit: BoxFit.fill,
                    ),
                  ] else
                    Expanded(
                      child: Image.asset(
                        'assets/images/${switch (variant) {
                          WallSegmentVariant.top => ImageAssets.terrainStoneVerticalTop,
                          WallSegmentVariant.middle => ImageAssets.terrainStoneVerticalMiddle,
                          WallSegmentVariant.bottom => ImageAssets.terrainStoneVerticalBottom,
                          WallSegmentVariant.auto => ImageAssets.terrainStoneVerticalMiddle,
                        }}',
                        width: width,
                        fit: BoxFit.fill,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: -4,
          top: -22,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1D3048),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
