import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:skwer/tetris/game_props.dart';
import 'package:skwer/tetris/game_tetramino.dart';
import 'package:skwer/tetris/level.dart';
import 'package:skwer/util/fast_key_focus_scope.dart';
import 'package:skwer/util/move_arrows.dart';
import 'package:skwer/util/value_change.dart';

class Game {
  static const Duration _spawnDuration = Duration(milliseconds: 30);
  static final Random _random = Random();

  final GameProps props = GameProps();
  final VoidCallback onExit;

  Duration _elapsed = const Duration();
  Duration? _waitStepStartTime;
  Duration? _waitSpawnStartTime;
  Set<TileIndex> _dropHintTiles = <TileIndex>{};
  int _floorSlideDirection = 0;

  Game(this.onExit) {
    props.tetramino.addListener(_updateTetramino);
  }

  void start() {
    for (final tile in props.tiles.values) {
      tile.color.value = null;
    }
    props.tetramino.value = ValueChange(null, null);
    props.isGameOver.value = false;
    props.score.value = 0;
    props.level.value = kLevels.first;
    _waitSpawnStartTime = _elapsed + const Duration(milliseconds: 500);
  }

  void update(Duration e) {
    if (props.isGameOver.value) {
      return;
    }

    _elapsed = e;

    if (_waitSpawnStartTime != null) {
      // Waiting for spawn...
      if (_elapsed - _waitSpawnStartTime! >= _spawnDuration) {
        _waitSpawnStartTime = null;
        _spawnTetramino();
      }
      return;
    }

    if (_waitStepStartTime != null) {
      // Waiting for step...
      if (_elapsed - _waitStepStartTime! >= props.level.value.stepDuration) {
        _waitStepStartTime = null;
        _stepTetramino();
      }
      return;
    }
  }

  void resize(int numTilesX, int numTilesY) {
    props.numTiles.value = Point(numTilesX, numTilesY);
    start();
  }

  KeyEventResult onKeyEvent(FastKeyEvent event) {
    if (event.type == FastKeyEventType.up) {
      return KeyEventResult.ignored;
    }

    if (props.isGameOver.value) {
      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        start();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyQ) {
        if (event.type == FastKeyEventType.down) {
          onExit();
          return KeyEventResult.handled;
        }
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _rotateTetramino();
      if (event.type == FastKeyEventType.repeat) {
        if (_waitStepStartTime != null) {
          _waitStepStartTime = _waitStepStartTime! -
              Duration(
                  milliseconds:
                      props.level.value.stepDuration.inMilliseconds ~/ 2);
        }
      }
      return KeyEventResult.handled;
    }

    final moveDirection =
        MoveArrows.getHorizontalDirection(props.keyFocusScopeController);
    if ((event.logicalKey == LogicalKeyboardKey.arrowLeft &&
            moveDirection == -1) ||
        (event.logicalKey == LogicalKeyboardKey.arrowRight &&
            moveDirection == 1)) {
      _translateTetramino(moveDirection, 0);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _dropTetramino();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  GameTetramino? _getNextSpawn() {
    final tetramino = props.nextTetramino.value;
    final gameTetramino = GameTetramino(
      tetramino,
      TileIndex(
        (props.numTiles.value.x / 2 - tetramino.spawnOffset().x).ceil(),
        (-tetramino.spawnOffset().y).round(),
      ),
      0,
    );
    if (!_isValidPosition(gameTetramino)) {
      return null;
    }
    if (props.numTilesX == 3) {
      props.nextTetramino.value =
          Tetramino.values[1 + _random.nextInt(Tetramino.values.length - 1)];
    } else {
      props.nextTetramino.value =
          Tetramino.values[_random.nextInt(Tetramino.values.length)];
    }
    return gameTetramino;
  }

  void _spawnTetramino() {
    final next = _getNextSpawn();
    if (next == null) {
      props.isGameOver.value = true;
      return;
    }

    _floorSlideDirection = 0;
    _waitStepStartTime = _elapsed;
    props.tetramino.value = ValueChange(null, next);
  }

  void _rotateTetramino() {
    final current = props.tetramino.value.value;
    if (current == null) {
      return;
    }

    final rotated = _findValidRotation(current);
    if (rotated == null) {
      return;
    }

    props.tetramino.value = ValueChange(current, rotated);
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
    final drop = _findDropDistance(current);
    _waitStepStartTime = _elapsed - props.level.value.stepDuration;
    props.tetramino.value = ValueChange(current, current.translate(0, drop));
  }

  void _stepTetramino() {
    final current = props.tetramino.value.value!;

    if (!_isTouchingFloor(current)) {
      _waitStepStartTime = _elapsed;
      props.tetramino.value = ValueChange(current, current.step());
      return;
    }

    if (_maybeFloorSlide()) {
      _waitStepStartTime = _elapsed - props.level.value.stepDuration;
      return;
    }

    _checkCompletedRows(current);
    _waitSpawnStartTime = _elapsed;
    props.tetramino.value = ValueChange(null, null);
  }

  void _checkCompletedRows(GameTetramino positioned) {
    final rowsToCheck = <int>{};
    for (final tile in positioned.tiles) {
      rowsToCheck.add(tile.y);
    }

    final completed = rowsToCheck.where(_isRowComplete);
    if (completed.isEmpty) {
      return;
    }
    props.score.value += completed.length;

    final nextLevel = props.level.value.next;
    if (nextLevel != null && nextLevel.score <= props.score.value) {
      props.level.value = nextLevel;
    }

    final sorted = completed.toList()..sort((a, b) => b - a);
    var copy = sorted.first - 1;
    for (var row = sorted.first; row >= 0; row--, copy--) {
      while (sorted.contains(copy)) {
        --copy;
      }
      if (!_copyRowToRow(copy, row)) {
        return;
      }
    }
  }

  bool _copyRowToRow(int copy, int paste) {
    var foundOccupied = false;
    for (var i = 0; i < props.numTilesX; i++) {
      final tileToCopy = copy >= 0 ? props.tiles[TileIndex(i, copy)]! : null;
      final tileToPaste = props.tiles[TileIndex(i, paste)]!;
      if (!foundOccupied && tileToPaste.isOccupied) {
        foundOccupied = true;
      }
      tileToPaste.color.value = tileToCopy?.color.value;
    }
    return foundOccupied;
  }

  bool _isRowComplete(int row) {
    for (var i = 0; i < props.numTilesX; i++) {
      if (!props.tiles[TileIndex(i, row)]!.isOccupied) {
        return false;
      }
    }
    return true;
  }

  void _updateTetramino() {
    _updateTetraminoTiles();
    _updateTetraminoDropHint();
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

  void _updateTetraminoDropHint() {
    final tetramino = props.tetramino.value.value;
    final Map<int, int> newDropHintIndices = <int, int>{};

    if (tetramino != null) {
      for (final tile in tetramino.tiles) {
        final floor = _findFloor(tile);
        if (floor != null) {
          newDropHintIndices[tile.x] = floor;
        }
      }
    }
    final Set<TileIndex> newDropHintTiles = newDropHintIndices.entries
        .map<TileIndex>((e) => TileIndex(e.key, e.value))
        .toSet();

    for (final tile in _dropHintTiles) {
      if (!newDropHintTiles.contains(tile)) {
        props.tiles[tile]?.dropHintColor.value = null;
      }
    }
    _dropHintTiles = newDropHintTiles;
    for (final tile in _dropHintTiles) {
      props.tiles[tile]!.dropHintColor.value = tetramino!.tetramino.color;
    }
  }

  int? _findFloor(TileIndex tile) {
    TileIndex? floor;
    var next = tile;
    while (true) {
      next = next.translate(0, 1);
      final nextTile = props.tiles[next];
      if (nextTile == null || nextTile.isOccupied) {
        return floor?.y;
      }
      floor = next;
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
          tile.y >= props.numTilesY ||
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

  bool _maybeFloorSlide() {
    final moveDirection =
        MoveArrows.getHorizontalDirection(props.keyFocusScopeController);
    if (moveDirection == 0) {
      return false;
    }

    final tetramino = props.tetramino.value.value!;
    final translated = tetramino.translate(moveDirection, 0);
    final slideDirection = _isValidPosition(translated) ? moveDirection : 0;
    if (slideDirection == 0) {
      return false;
    }

    if (_floorSlideDirection != 0 && _floorSlideDirection != slideDirection) {
      return false;
    }

    _floorSlideDirection = slideDirection;
    return true;
  }

  GameTetramino? _findValidRotation(GameTetramino tetramino) {
    final rotated = tetramino.rotate();
    if (_isValidPosition(rotated)) {
      return rotated;
    }

    for (final wallKickTest
        in tetramino.tetramino.wallKickTests(tetramino.rotation)) {
      final translated = rotated.translate(wallKickTest.x, wallKickTest.y);
      if (_isValidPosition(translated)) {
        return translated;
      }
    }
    return null;
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
