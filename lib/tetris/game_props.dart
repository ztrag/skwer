import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:skwer/tetris/game_tetramino.dart';
import 'package:skwer/tetris/game_tile_props.dart';
import 'package:skwer/util/value_change.dart';

class GameProps {
  final ValueNotifier<Point<int>> numTiles =
      ValueNotifier(const Point<int>(0, 0));

  final Map<TileIndex, GameTileProps> tiles = <TileIndex, GameTileProps>{};

  ValueListenable<ValueChange<GameTetramino?>> get tetramino => _tetramino;

  final ValueNotifier<ValueChange<GameTetramino?>> _tetramino =
      ValueNotifier(ValueChange<GameTetramino?>(null, null));

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

  void spawnTetramino(GameTetramino tetramino) {
    _tetramino.value = ValueChange(null, tetramino);
  }

  void rotateTetramino() {
    final current = tetramino.value.value;
    if (current == null) {
      return;
    }

    _tetramino.value = ValueChange(current, current.rotate());
  }
}
