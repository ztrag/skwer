import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:skwer/tetris/game_props.dart';
import 'package:skwer/tetris/game_tetramino.dart';
import 'package:skwer/util/value_change.dart';

class Game {
  final GameProps props = GameProps();

  Duration _elapsed = const Duration();
  Duration _lastStep = const Duration();
  final Duration _stepDuration = const Duration(seconds: 1);
  final Duration _spawnDuration = const Duration(milliseconds: 200);
  final Random _random = Random();

  Game() {
    props.tetramino.addListener(_updateTetraminoTiles);
  }

  void start() {
    for (final tile in props.tiles.values) {
      tile.color.value = null;
    }
    props.tetramino.value = ValueChange(null, null);
    props.isGameOver.value = false;
    _lastStep = _elapsed;
  }

  void update(Duration e) {
    if (props.isGameOver.value) {
      return;
    }

    _elapsed = e;
    final elapsedSinceStep = _elapsed - _lastStep;
    if (props.tetramino.value.value == null) {
      if (elapsedSinceStep >= _spawnDuration) {
        _lastStep = _elapsed;
        _spawnTetramino();
      }
      return;
    }

    if (_elapsed - _lastStep >= _stepDuration) {
      _lastStep = _elapsed;
      _stepTetramino();
    }
  }

  void resize(int numTilesX, int numTilesY) {
    props.numTiles.value = Point(numTilesX, numTilesY);
    start();
  }

  KeyEventResult onKeyEvent(KeyEvent event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _rotateTetramino();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _translateTetramino(
          event.logicalKey == LogicalKeyboardKey.arrowLeft ? -1 : 1, 0);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _dropTetramino();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  GameTetramino? _getNextSpawn() {
    final tetramino =
        Tetramino.values[_random.nextInt(Tetramino.values.length)];
    final gameTetramino = GameTetramino(
      tetramino,
      TileIndex(
        props.numTiles.value.x ~/ 2 - tetramino.spawnOffset().x,
        -tetramino.spawnOffset().y,
      ),
      0,
    );
    if (!_isValidPosition(gameTetramino)) {
      return null;
    }
    return gameTetramino;
  }

  void _spawnTetramino() {
    final next = _getNextSpawn();
    if (next == null) {
      props.isGameOver.value = true;
      return;
    }

    props.tetramino.value = ValueChange(null, next);
  }

  void _rotateTetramino() {
    final current = props.tetramino.value.value;
    if (current == null) {
      return;
    }
    // TODO boundary kick
    props.tetramino.value = ValueChange(current, current.rotate());
  }

  void _translateTetramino(int x, int y) {
    final current = props.tetramino.value.value;
    if (current == null) {
      return;
    }
    final translated = current.translate(x, y);
    if (!_isValidPosition(translated)) {
      return;
    }
    props.tetramino.value = ValueChange(current, current.translate(x, y));
  }

  void _dropTetramino() {
    final current = props.tetramino.value.value;
    if (current == null) {
      return;
    }
    _lastStep = _elapsed - _stepDuration;
    final drop = _findDropDistance(current);
    props.tetramino.value = ValueChange(current, current.translate(0, drop));
  }

  void _stepTetramino() {
    final current = props.tetramino.value.value;
    if (current == null) {
      _spawnTetramino();
      return;
    }

    if (_isTouchingFloor(current)) {
      props.tetramino.value = ValueChange(null, null);
      // TODO maybe delete row...
      return;
    }

    props.tetramino.value = ValueChange(current, current.step());
  }

  void _updateTetraminoTiles() {
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
      props.tiles[tile]!.color.value =
          props.tetramino.value.value!.tetramino.color;
    }
  }

  bool _isTouchingFloor(GameTetramino tetramino) {
    final tiles = tetramino.tiles;
    for (final tile in tiles) {
      if (tile.y == props.numTiles.value.y - 1) {
        return true;
      }
      final next = tile.translate(0, 1);
      if (props.tiles[next]!.isOccupied && !tiles.contains(next)) {
        return true;
      }
    }
    return false;
  }

  bool _isValidPosition(GameTetramino tetramino) {
    final current = props.tetramino.value.value?.tiles;
    final test = tetramino.tiles;
    for (final tile in test) {
      if (tile.y < 0 ||
          tile.y >= props.numTilesY - 1 ||
          tile.x < 0 ||
          tile.x >= props.numTilesX) {
        return false;
      }
      if (props.tiles[tile]!.isOccupied &&
          (current == null || !current.contains(tile))) {
        return false;
      }
    }
    return true;
  }

  int _findDropDistance(GameTetramino tetramino) {
    final tiles = tetramino.tiles;
    final Map<int, int> low = {};
    for (final tile in tiles) {
      final curr = low[tile.x];
      if (curr == null || curr < tile.y) {
        low[tile.x] = tile.y;
      }
    }
    int i = 0;
    while (true) {
      for (final lowTile in low.entries) {
        if (lowTile.value + i + 1 == props.numTilesY ||
            props.tiles[TileIndex(lowTile.key, lowTile.value + i + 1)]!
                .isOccupied) {
          return i;
        }
      }
      ++i;
    }
  }
}
