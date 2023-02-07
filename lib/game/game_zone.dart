import 'dart:math';

class GameZone {
  final Point<int> start;
  final Point<int> size;

  GameZone._(this.start, this.size);

  factory GameZone(int numTilesX, int numTilesY) {
    final paddingX = numTilesX <= 7 ? 1 : 2;
    final paddingY = numTilesY <= 7 ? 1 : 2;
    return GameZone._(
      Point(paddingX, paddingY),
      Point(numTilesX - paddingX * 2, numTilesY - paddingY * 2),
    );
  }
}
