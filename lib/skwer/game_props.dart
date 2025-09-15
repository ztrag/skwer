import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:skwer/skwer/puzzle.dart';
import 'package:skwer/tile/skwer_tile_props.dart';
import 'package:skwer/tile/tile_index.dart';

class GameProps {
  final ValueNotifier<int> skwer = ValueNotifier(0);
  final ValueNotifier<Point<int>> numTiles =
      ValueNotifier(const Point<int>(0, 0));
  final ValueNotifier<Puzzle?> puzzle = ValueNotifier(null);
  final ValueNotifier<bool> isSolved = ValueNotifier(true);
  final ValueNotifier<int> rotationCounter = ValueNotifier(0);

  final Map<TileIndex, SkwerTileProps> skwerTiles =
      <TileIndex, SkwerTileProps>{};

  GameProps() {
    numTiles.addListener(() {
      skwerTiles.removeWhere(
        (key, _) => key.x >= numTilesX || key.y >= numTilesY,
      );
      for (var x = 0; x < numTilesX; x++) {
        for (var y = 0; y < numTilesY; y++) {
          final tileIndex = TileIndex(x, y);
          skwerTiles[tileIndex] =
              skwerTiles[tileIndex] ?? SkwerTileProps(index: tileIndex);
        }
      }
    });
  }

  bool isTileActive(TileIndex index) {
    var currentPuzzle = puzzle.value;
    if (currentPuzzle == null) {
      return true;
    }
    return currentPuzzle.zone.containsTile(index);
  }

  bool get hasPuzzle => puzzle.value != null;

  int get puzzleLength => puzzle.value?.rotations.length ?? 0;

  int get numTilesX => numTiles.value.x;

  int get numTilesY => numTiles.value.y;
}
