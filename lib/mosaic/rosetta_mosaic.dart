import 'dart:math';

import 'package:skwer/mosaic/mosaic.dart';
import 'package:skwer/mosaic/mosaic_tile.dart';

class MosaicRosetta extends Mosaic {
  static final Random _random = Random();

  List<MosaicTile>? _tiles;

  MosaicRosetta();

  @override
  List<MosaicTile> get tiles => _tiles ??= _buildTiles();

  List<MosaicTile> _buildTiles() {
    final tiles = <MosaicTile>[];
    tiles.add(_buildCenterStone());
    tiles.addAll(_buildArc(1));
    tiles.addAll(_buildArc(2));
    tiles.addAll(_buildArc(3));
    tiles.addAll(_buildArc(4));
    return tiles;
  }

  MosaicTile _buildCenterStone() {
    final r = _radiusAtLevel(1) - 0.03;
    const step = pi / 3.5;
    var theta = _random.nextDouble() * 2 * pi;
    var left = 2 * pi;
    final points = <Point<double>>[_pointAt(r, theta)];
    while (left > step) {
      final next = step * (1 + (-0.5 + _random.nextDouble()));
      left -= next;
      theta += next;
      points.add(_pointAt(r, theta));
    }
    return MosaicTile(points);
  }

  List<MosaicTile> _buildArc(int level) {
    final r1 = _radiusAtLevel(level) + 0.01;
    final r2 = _radiusAtLevel(level + 1) - 0.01;
    final numStones = _stonesAtLevel(level);
    final step = 2 * pi / numStones;
    var theta = _random.nextDouble() * 2 * pi;
    if (level == 4) {
      theta = pi / 4;
    }
    final stones = <MosaicTile>[];
    final thetaD1 = pi * 0.02 / level;
    for (var i = 0; i < numStones; i++) {
      stones.add(
          _buildStone(r1, r2, theta + thetaD1, theta + step - thetaD1, level));
      theta += step;
    }
    return stones;
  }

  MosaicTile _buildStone(
      double r1, double r2, double theta1, double theta2, int level) {
    final thetaD2 = 0.04 * _random.nextDouble() / level;
    return MosaicTile([
      _pointAt(r1, theta1),
      _pointAt(r2, theta1 + thetaD2),
      _pointAt(r2, theta2 - thetaD2),
      _pointAt(r1, theta2),
    ]);
  }

  double _radiusAtLevel(int level) {
    if (level == 1) {
      return 0.08;
    } else if (level == 2) {
      return 0.20;
    } else if (level == 3) {
      return 0.34;
    } else if (level == 4) {
      return 0.48;
    }
    return 0.75;
  }

  int _stonesAtLevel(int level) {
    if (level == 1) {
      return 7;
    } else if (level == 2) {
      return 10;
    } else if (level == 3) {
      return 16;
    }
    return 20;
  }

  Point<double> _pointAt(double r, double theta) {
    final pointX = r * cos(theta);
    final pointY = r * sin(theta);
    var r0 = 1.0;
    if (pointX < -0.5) {
      r0 = min(r0, r * (0.5 / -pointX));
    }
    if (pointY < -0.5) {
      r0 = min(r0, r * (0.5 / -pointY));
    }
    if (pointX > 0.5) {
      r0 = min(r0, r * (0.5 / pointX));
    }
    if (pointY > 0.5) {
      r0 = min(r0, r * (0.5 / pointY));
    }

    final r1 = min(r0, r);
    final point = Point(
      0.5 + r1 / r * _d2 * pointX,
      0.5 + r1 / r * _d2 * pointY,
    );
    return point;
  }

  static double get _d2 {
    const d2 = 0.05;
    return (1 - d2 / 2 + d2 * _random.nextDouble());
  }
}
