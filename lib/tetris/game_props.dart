import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:skwer/tetris/game_tetramino.dart';
import 'package:skwer/tetris/game_tile_props.dart';
import 'package:skwer/tetris/level.dart';
import 'package:skwer/util/value_change.dart';

class GameProps {
  final ValueNotifier<Point<int>> numTiles =
      ValueNotifier(const Point<int>(0, 0));
  final Map<TileIndex, GameTileProps> tiles = <TileIndex, GameTileProps>{};

  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<Level> level = ValueNotifier(kLevels.first);
  final ValueNotifier<bool> isGameOver = ValueNotifier(false);

  final ValueNotifier<ValueChange<GameTetramino?>> tetramino =
      ValueNotifier(ValueChange<GameTetramino?>(null, null));
  final ValueNotifier<Tetramino> nextTetramino = ValueNotifier(
      Tetramino.values[Random().nextInt(Tetramino.values.length)]);

  GameProps() {
    numTiles.addListener(() {
      tiles.removeWhere(
        (key, _) => key.x >= numTilesX || key.y >= numTilesY,
      );
      for (var x = 0; x < numTilesX; x++) {
        for (var y = 0; y < numTilesY; y++) {
          final tileIndex = TileIndex(x, y);
          tiles[tileIndex] = tiles[tileIndex] ?? GameTileProps(tileIndex);
        }
      }
    });
  }

  int get numTilesX => numTiles.value.x;

  int get numTilesY => numTiles.value.y;
}
