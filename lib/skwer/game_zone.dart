import 'dart:math';

import 'package:skwer/tile/tile_index.dart';

class GameZone {
  final Point<int> start;
  final Point<int> size;

  GameZone._(this.start, this.size);

  factory GameZone(int numTilesX, int numTilesY, Point<int> zoneSize) {
    final paddingX = (numTilesX - zoneSize.x) ~/ 2;
    final paddingY = (numTilesY - zoneSize.y) ~/ 2;
    return GameZone._(
      Point(paddingX, paddingY),
      Point(numTilesX - paddingX * 2, numTilesY - paddingY * 2),
    );
  }

  bool containsTile(TileIndex tile) {
    return tile.x >= start.x &&
        tile.y >= start.y &&
        tile.x - start.x < size.x &&
        tile.y - start.y < size.y;
  }
}
