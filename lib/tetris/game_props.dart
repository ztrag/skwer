import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:skwer/tetris/game_prefs.dart';
import 'package:skwer/tetris/game_tetramino.dart';
import 'package:skwer/tetris/game_tile_props.dart';
import 'package:skwer/tetris/level.dart';
import 'package:skwer/util/fast_key_focus.dart';
import 'package:skwer/util/touch_arrows.dart';
import 'package:skwer/util/value_change.dart';

class GameProps {
  final ValueNotifier<Point<int>> numTiles =
      ValueNotifier(const Point<int>(0, 0));
  final Map<TileIndex, GameTileProps> tiles = <TileIndex, GameTileProps>{};

  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<Level> level = ValueNotifier(kLevels.first);
  final ValueNotifier<bool> isGameOver = ValueNotifier(false);
  final ValueNotifier<bool> isPaused = ValueNotifier(false);

  final ValueNotifier<ValueChange<GameTetramino?>> tetramino =
      ValueNotifier(ValueChange<GameTetramino?>(null, null));
  final ValueNotifier<Tetramino> nextTetramino = ValueNotifier(Tetramino.t);

  final FastKeyFocusController keyFocusScopeController =
      FastKeyFocusController();
  final TouchArrowsController touchArrowsController = TouchArrowsController();

  final GamePrefs prefs = GamePrefs();

  final VoidCallback onExit;
  final VoidCallback onStart;

  FastKeyEventCallback? onOverlayKeyEvent;

  GameProps({required this.onStart, required this.onExit}) {
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

  bool get isShowingOverlay => isPaused.value || isGameOver.value;
}
