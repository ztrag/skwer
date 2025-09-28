import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:skwer/tetris/game_board.dart';
import 'package:skwer/tetris/game_props.dart';
import 'package:skwer/tetris/game_tetramino.dart';
import 'package:skwer/tetris/level.dart';
import 'package:skwer/util/fast_key_focus.dart';
import 'package:skwer/util/move_arrows.dart';
import 'package:skwer/util/touch_arrows.dart';
import 'package:skwer/util/value_change.dart';

class Game {
  static const Duration _spawnDuration = Duration(milliseconds: 30);
  static final Random _random = Random();

  final GameProps props;

  Duration _elapsed = const Duration();
  Duration? _nextStepTime;
  Duration? _waitSpawnStartTime;
  Duration? _lastMovementTime;
  Duration _pausedTime = const Duration();
  Duration? _onPauseTime;

  Set<TileIndex> _dropHintTiles = <TileIndex>{};

  Game(this.props) {
    props.tetramino.addListener(_updateTetramino);
    props.isPaused.addListener(_onPauseToggled);
  }

  void start() {
    props.boardSizeHintController.forward(from: 0.0);
    for (final tile in props.tiles.values) {
      tile.color.value = null;
    }
    _onPauseTime = null;
    _waitSpawnStartTime = _elapsed + const Duration(milliseconds: 500);
    _toggleNextTetramino();

    props.tetramino.value = ValueChange(null, null);
    props.isGameOver.value = false;
    props.isPaused.value = false;
    props.score.value = 0;
    props.level.value = kLevels.first;
  }

  void update(Duration e) {
    _elapsed = e - _pausedTime;

    if (props.isShowingOverlay) {
      return;
    }

    if (_waitSpawnStartTime != null) {
      // Waiting for spawn...
      if (_elapsed - _waitSpawnStartTime! >= _spawnDuration) {
        _waitSpawnStartTime = null;
        _spawnTetramino();
      }
      return;
    }

    if (_nextStepTime != null) {
      // Waiting for step...
      if (_elapsed > _nextStepTime!) {
        _nextStepTime = null;
        _stepTetramino();
      }
      return;
    }
  }

  void resize(int numTilesX, int numTilesY) {
    props.numTiles.value = Point(numTilesX, numTilesY);
    start();
  }

  GameBoard onBoardSizeToggled() {
    final initialLevel = props.prefs.boardSizeLevel;
    final initialGameBoard = GameBoard.fromProps(props);
    props.prefs.boardSizeLevel++;
    while (props.prefs.boardSizeLevel != initialLevel) {
      final gameBoard = GameBoard.fromProps(props);
      if (!gameBoard.isTooSmall &&
          (gameBoard.numTilesX != initialGameBoard.numTilesX ||
              gameBoard.numTilesY != initialGameBoard.numTilesY)) {
        return gameBoard;
      }
      props.prefs.boardSizeLevel++;
    }
    return initialGameBoard;
  }

  void onTouchArrowEvent(TouchArrowEvent event) {
    if (event.type == TouchArrowEventType.up) {
      return;
    }

    switch (event.direction) {
      case Direction.left:
        _onArrowHorizontal(-1);
        break;
      case Direction.right:
        _onArrowHorizontal(1);
        break;
      case Direction.up:
        _onArrowUp(event.type == TouchArrowEventType.repeat);
        break;
      case Direction.down:
        if (event.type == TouchArrowEventType.down) {
          _onArrowDown();
        }
        break;
    }
  }

  KeyEventResult onKeyEvent(FastKeyEvent event) {
    if (props.isShowingOverlay) {
      if (props.onOverlayKeyEvent != null) {
        return props.onOverlayKeyEvent!(event);
      }
      return KeyEventResult.ignored;
    }

    if (event.type == FastKeyEventType.up) {
      return KeyEventResult.ignored;
    }

    if (event.type == FastKeyEventType.down &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      props.isPaused.value = true;
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _onArrowUp(event.type == FastKeyEventType.repeat);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _onArrowHorizontal(
          event.logicalKey == LogicalKeyboardKey.arrowLeft ? -1 : 1);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _onArrowDown();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.backslash &&
        event.type == FastKeyEventType.down) {
      onBoardSizeToggled();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyD &&
        event.type == FastKeyEventType.down) {
      props.prefs.isDropHintEnabled = !props.prefs.isDropHintEnabled;
      _updateTetraminoDropHint();
     return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _onArrowHorizontal(int dir) {
    final moveDirection = MoveArrows.getHorizontalDirection(
      props.keyFocusScopeController,
      props.touchArrowsController,
    );
    if (dir == moveDirection) {
      _translateTetramino(moveDirection);
    }
  }

  void _onArrowUp(bool isRepeat) {
    _rotateTetramino();
    if (isRepeat) {
      if (_nextStepTime != null) {
        _nextStepTime = _nextStepTime! -
            Duration(
                milliseconds:
                    props.level.value.stepDuration.inMilliseconds ~/ 2);
      }
    }
  }

  void _onArrowDown() {
    _dropTetramino();
  }

  void _onPauseToggled() {
    if (props.isPaused.value) {
      _onPauseTime = _elapsed;
    } else if (_onPauseTime != null) {
      _pausedTime += _elapsed - _onPauseTime!;
    }
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
    _toggleNextTetramino();
    return gameTetramino;
  }

  void _toggleNextTetramino() {
    if (props.numTilesX == 3) {
      props.nextTetramino.value =
          Tetramino.values[1 + _random.nextInt(Tetramino.values.length - 1)];
    } else {
      props.nextTetramino.value =
          Tetramino.values[_random.nextInt(Tetramino.values.length)];
    }
  }

  void _spawnTetramino() {
    final next = _getNextSpawn();
    if (next == null) {
      props.isGameOver.value = true;
      return;
    }

    _nextStepTime = _elapsed + props.level.value.stepDuration;
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

    _lastMovementTime = _elapsed;
    props.tetramino.value = ValueChange(current, rotated);
  }

  void _translateTetramino(int x) {
    final current = props.tetramino.value.value;
    if (current == null) {
      return;
    }
    final translated = current.translate(x, 0);
    if (!_isValidPosition(translated)) {
      return;
    }

    _lastMovementTime = _elapsed;
    props.tetramino.value = ValueChange(current, current.translate(x, 0));
  }

  void _dropTetramino() {
    final current = props.tetramino.value.value;
    if (current == null) {
      return;
    }
    final drop = _findDropDistance(current);
    _nextStepTime = _elapsed;
    _lastMovementTime = null;
    props.tetramino.value = ValueChange(current, current.translate(0, drop));
  }

  void _stepTetramino() {
    final current = props.tetramino.value.value!;

    if (!_isTouchingFloor(current)) {
      _nextStepTime = _elapsed + props.level.value.stepDuration;
      props.tetramino.value = ValueChange(current, current.step());
      return;
    }

    final floorSlideDelay = _getFloorSlideDelay();
    if (floorSlideDelay != null) {
      _nextStepTime = _elapsed + floorSlideDelay;
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
    if (props.prefs.isDropHintEnabled) {
      _updateTetraminoDropHint();
    }
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

    if (tetramino != null && props.prefs.isDropHintEnabled) {
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

  Duration? _getFloorSlideDelay() {
    if (_lastMovementTime == null) {
      return null;
    }
    final delta = _elapsed - _lastMovementTime!;
    const delay = Duration(milliseconds: 200);
    return delta > delay ? null : delay - delta;
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
