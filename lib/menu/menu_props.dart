import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:skwer/menu/menu_tile_props.dart';

class MenuProps {
  final ValueNotifier<Point<int>> numTiles =
      ValueNotifier(const Point<int>(0, 0));
  final Map<Point<int>, MenuTileProps> tiles = <Point<int>, MenuTileProps>{};

  Point<int> bgAnchor = const Point(0, 0);

  MenuProps() {
    numTiles.addListener(() {
      bgAnchor = Point(numTilesX ~/ 2 - 1, (numTilesY - 2) ~/ 2);
      tiles.removeWhere(
        (key, _) => key.x >= numTilesX || key.y >= numTilesY,
      );
      for (var x = 0; x < numTilesX; x++) {
        for (var y = 0; y < numTilesY; y++) {
          final tileIndex = Point(x, y);
          tiles[tileIndex] =
              tiles[tileIndex] ?? MenuTileProps(index: tileIndex);
        }
      }
    });
  }

  int get numTilesX => numTiles.value.x;

  int get numTilesY => numTiles.value.y;
}
