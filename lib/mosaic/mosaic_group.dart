import 'dart:ui';

import 'package:skwer/mosaic/mosaic_animation.dart';
import 'package:skwer/mosaic/mosaic_tile.dart';

abstract class MosaicGroup {
  List<MosaicTile> get tiles;

  void paint(
    Canvas canvas,
    Size size,
    double brightness,
    MosaicAnimation animation,
  ) {
    for (MosaicTile tile in tiles) {
      tile.paint(canvas, size, brightness, animation);
    }
  }
}
