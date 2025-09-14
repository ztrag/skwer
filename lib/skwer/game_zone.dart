import 'dart:math';

import 'package:skwer/tile/skwer_tile_index.dart';

class GameZone {
  final Point<int> start;
  final Point<int> size;

  GameZone._(this.start, this.size);

  factory GameZone(int numTilesX, int numTilesY) {
    final paddingX = _paddingForTiles(numTilesX);
    var paddingY = _paddingForTiles(numTilesY);
    if (paddingX == 1 && paddingY == 1 && numTilesY > 5 && numTilesX <= 5) {
      paddingY = 2;
    }
    return GameZone._(
      Point(paddingX, paddingY),
      Point(numTilesX - paddingX * 2, numTilesY - paddingY * 2),
    );
  }

  static int _paddingForTiles(int numTiles) {
    if (numTiles >= 10) {
      return (6 + numTiles - 10) ~/ 2;
    } else if (numTiles > 6) {
      return 2;
    } else if (numTiles > 3) {
      return 1;
    }
    return 0;
  }

  bool containsTile(SkwerTileIndex tile) {
    return tile.x >= start.x &&
        tile.y >= start.y &&
        tile.x - start.x < size.x &&
        tile.y - start.y < size.y;
  }
}
