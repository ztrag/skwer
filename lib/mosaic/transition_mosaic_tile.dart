import 'dart:math';

import 'mosaic_tile.dart';

class TransitionMosaicTile extends MosaicTile {
  final MosaicTile tileA;
  final MosaicTile tileB;

  double transition = 0;

  TransitionMosaicTile(this.tileA, this.tileB)
      : super([
          ...tileA.points,
          ...tileB.points,
        ]);

  @override
  List<Point<double>> getAnimatedPoints(double animation) {
    final a = tileA.getAnimatedPoints(animation);
    final b = tileB.getAnimatedPoints(animation);
    final points = <Point<double>>[];
    final offset = _getBestMatchOffset(a, b);

    for (var i = 0; i < max(a.length, b.length); i++) {
      if (i < b.length) {
        points.add(
          a[min(i, a.length - 1)] * (1 - transition) +
              b[(min(i, b.length - 1) + offset) % b.length] * transition,
        );
      }
    }
    return points;
  }

  int _getBestMatchOffset(List<Point<double>> a, List<Point<double>> b) {
    var best = 0;
    var bestDist = 1000.0;
    for (var j = 0; j < b.length; j++) {
      var dist = 0.0;
      for (var i = 0; i < max(a.length, b.length); i++) {
        dist += a[min(i, a.length - 1)]
            .squaredDistanceTo(b[(min(i, b.length - 1) + j) % b.length]);
      }
      if (dist < bestDist) {
        bestDist = dist;
        best = j;
      }
    }
    return best;
  }

  @override
  double get getAnimatedColorD1 =>
      tileA.getAnimatedColorD1 * (1 - transition) +
      tileB.getAnimatedColorD1 * transition;
}
