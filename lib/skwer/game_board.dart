import 'dart:math';

import 'package:skwer/skwer/game_zone.dart';

class GameBoard {
  final Point<int> size;
  final Point<int> zoneSize;

  const GameBoard(this.size, this.zoneSize);

  factory GameBoard.empty() {
    return const GameBoard(Point(0, 0), Point(0, 0));
  }

  @override
  int get hashCode => size.hashCode * 1234 + zoneSize.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! GameBoard) {
      return false;
    }
    return other.size == size && other.zoneSize == zoneSize;
  }

  bool operator <(Object other) {
    if (other is! GameBoard) {
      return false;
    }
    return other != this &&
        zoneSize.x <= other.zoneSize.x &&
        zoneSize.y <= other.zoneSize.y;
  }

  factory GameBoard.forTargetZone(
    Point<int> maxSize,
    Point<int> targetZoneSize,
  ) {
    final zoneSize = Point(
      min(targetZoneSize.x, _getZoneForTarget(maxSize.x, targetZoneSize.x)),
      min(targetZoneSize.y, _getZoneForTarget(maxSize.y, targetZoneSize.y)),
    );
    final size = Point(
      maxSize.x % 2 == zoneSize.x % 2 ? maxSize.x : maxSize.x - 1,
      maxSize.y % 2 == zoneSize.y % 2 ? maxSize.y : maxSize.y - 1,
    );
    return GameBoard(size, zoneSize);
  }

  static int _getZoneForTarget(int size, int target) {
    if (size <= 3) {
      return size;
    } else if (size <= 5) {
      return size - 2;
    } else if (size <= 9) {
      return size - 4;
    }
    return target;
  }

  GameZone get zone => GameZone(size.x, size.y, zoneSize);
}
