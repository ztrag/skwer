import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:skwer/skwer/game_board.dart';
import 'package:skwer/skwer/puzzle.dart';
import 'package:skwer/tile/skwer_tile_props.dart';
import 'package:skwer/tile/tile_index.dart';
import 'package:skwer/util/fast_key_focus_scope.dart';

class GameProps {
  final ValueNotifier<int> skwer = ValueNotifier(0);
  final ValueNotifier<Point<double>> size = ValueNotifier(const Point(0, 0));
  final ValueNotifier<double> tileSize = ValueNotifier(0);
  final ValueNotifier<GameBoard> board = ValueNotifier(GameBoard.empty());
  final ValueNotifier<Puzzle?> puzzle = ValueNotifier(null);
  final ValueNotifier<bool> isSolved = ValueNotifier(true);
  final ValueNotifier<int> rotationCounter = ValueNotifier(0);
  final ValueNotifier<bool> isShowingOverlay = ValueNotifier(false);

  final Map<TileIndex, SkwerTileProps> skwerTiles =
      <TileIndex, SkwerTileProps>{};

  final VoidCallback onExit;

  FastKeyEventCallback? onOverlayKeyEvent;

  GameProps(this.onExit) {
    board.addListener(() {
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

  int get numTilesX => board.value.size.x;

  int get numTilesY => board.value.size.y;
}
