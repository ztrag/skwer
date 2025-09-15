import 'dart:math';

import 'package:skwer/colors.dart';
import 'package:skwer/tetris/game_props.dart';
import 'package:skwer/tetris/game_tetramino.dart';

class Game {
  final GameProps props = GameProps();

  Game() {
    props.tetramino.addListener(_updateTetramino);
  }

  void resize(int numTilesX, int numTilesY) {
    props.numTiles.value = Point(numTilesX, numTilesY);
    start();
  }

  void start() {
    props.spawnTetramino(const GameTetramino(
      Tetramino.z,
      TileIndex(5, 10),
      0,
      skGreen,
    ));
  }

  void _updateTetramino() {
    final oldTiles = props.tetramino.value.old?.tiles ?? [];
    final newTiles = props.tetramino.value.value?.tiles ?? [];

    for (final tile in oldTiles) {
      if (newTiles.contains(tile)) {
        continue;
      }
      props.tiles[tile]!.color.value = null;
    }
    for (final tile in newTiles) {
      if (oldTiles.contains(tile)) {
        continue;
      }
      props.tiles[tile]!.color.value = props.tetramino.value.value!.color;
    }
  }

  void update() {}
}
