import 'dart:math';
import 'dart:ui';

import 'package:skwer/mosaic/color_wave.dart';
import 'package:skwer/mosaic/mosaic_tile.dart';

abstract class Mosaic {
  List<MosaicTile> get tiles;

  void paint(
    Canvas canvas,
    Size size,
    double brightness,
    double pressAnimation,
    ColorWave wave,
    Offset? hoverPosition,
  ) {
    for (MosaicTile tile in tiles) {
      tile.paint(
        canvas,
        size,
        brightness * _getHoverBrightness(tile, hoverPosition, size),
        pressAnimation,
        wave,
      );
    }
  }

  double _getHoverBrightness(
      MosaicTile tile, Offset? hoverPosition, Size size) {
    if (hoverPosition == null) {
      return 1;
    }
    final dist = Offset(tile.position.x - hoverPosition.dx / size.width,
            tile.position.y - hoverPosition.dy / size.height)
        .distance;
    final dist2 = max(0, (1.4142 - dist) / 1.4142);
    return 0.35 + 1 * pow(dist2, 1.5);
  }
}
