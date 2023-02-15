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
  ) {
    for (MosaicTile tile in tiles) {
      tile.paint(canvas, size, brightness, pressAnimation, wave);
    }
  }
}
