import 'dart:math';

import 'package:skwer/mosaic/mosaic.dart';
import 'package:skwer/mosaic/mosaic_tile.dart';

class GridMosaic extends Mosaic {
  static const int gridSize = 5;
  static final Random _random = Random();

  List<MosaicTile>? _tiles;

  @override
  List<MosaicTile> get tiles => _tiles ??= _buildTiles();

  List<MosaicTile> _buildTiles() {
    final tiles = <MosaicTile>[];
    final vertices = _calcVertices();
    const space = 0.01;
    for (var i = 0; i < gridSize; i++) {
      for (var j = 0; j < gridSize; j++) {
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
    for (var i = 0; i <= gridSize; i++) {
      vertices.add(<Point<double>>[]);
      for (var j = 0; j <= gridSize; j++) {
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
