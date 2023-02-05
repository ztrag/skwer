import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:skwer/mosaic/mosaic_animation.dart';
import 'package:skwer/mosaic/mosaic_tile.dart';

class MosaicGrid {
  static final Random _random = Random();

  final int gridSize = Platform.isAndroid || Platform.isIOS ? 5 : 7;

  List<MosaicTile>? _tiles;

  MosaicGrid();

  void paint(Canvas canvas, Size size, MosaicAnimation animationState) {
    final tiles = _tiles ??= _buildTiles();
    for (MosaicTile tile in tiles) {
      tile.paint(
        canvas,
        size,
        animationState,
      );
    }
  }

  List<MosaicTile> _buildTiles() {
    final tiles = <MosaicTile>[];
    final vertices = _calcVertices();
    const space = 0.01;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        tiles.add(MosaicTile([
          vertices[i][j] + Point(space * _d1, space * _d1),
          vertices[i + 1][j] + Point(-space * _d1, space * _d1),
          vertices[i + 1][j + 1] + Point(-space * _d1, -space * _d1),
          vertices[i][j + 1] + Point(space * _d1, -space * _d1),
        ]));
      }
    }
    return tiles;
  }

  List<List<Point<double>>> _calcVertices() {
    final vertices = <List<Point<double>>>[];
    for (int i = 0; i <= gridSize; i++) {
      vertices.add(<Point<double>>[]);
      for (int j = 0; j <= gridSize; j++) {
        vertices[i].add(_getVertex(vertices, i, j));
      }
    }
    return vertices;
  }

  Point<double> _getVertex(List<List<Point<double>>> vertices, int i, int j) {
    return Point(_getNextX(vertices, i, j), _getNextY(vertices, i, j));
  }

  double _getNextX(List<List<Point<double>>> vertices, int i, int j) {
    if (i == 0) {
      return 0;
    } else if (i == gridSize) {
      return 1;
    }
    return _getNextPos(vertices[i - 1][j].x, 1, gridSize - i);
  }

  double _getNextY(List<List<Point<double>>> vertices, int i, int j) {
    if (j == 0) {
      return 0;
    } else if (j == gridSize) {
      return 1;
    }
    return _getNextPos(vertices[i][j - 1].y, 1, gridSize - j);
  }

  double _getNextPos(double last, double end, int spacesLeft) {
    final x = (end - last) / (spacesLeft + 1);
    return last + x * _d2;
  }

  static double get _d1 {
    const d1 = 1.75;
    return (1 - d1 / 2 + d1 * _random.nextDouble());
  }

  static double get _d2 {
    const d2 = 0.5;
    return (1 - d2 / 2 + d2 * _random.nextDouble());
  }
}
