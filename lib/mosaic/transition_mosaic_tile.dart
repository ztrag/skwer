import 'dart:math';

import 'mosaic_tile.dart';

class TransitionMosaicTile extends MosaicTile {
  final MosaicTile tileA;
  final MosaicTile tileB;

  int dir = 1;

  TransitionMosaicTile(this.tileA, this.tileB)
      : super([
          ...tileA.points,
          ...tileB.points,
        ]);

  @override
  List<Point<double>> getAnimatedPoints(double animation) {
    if (animation < 0.5) {
      return (dir == 1 ? tileA : tileB).getAnimatedPoints(animation * 2);
    }
    return (dir == 1 ? tileB : tileA).getAnimatedPoints((animation - 0.5) * 2);
  }

  @override
  double getAnimatedColorD1(double animation) {
    if (animation < 0.5) {
      return (dir == 1 ? tileA : tileB).colorD1;
    }
    return (dir == 1 ? tileB : tileA).colorD1;
  }
}
