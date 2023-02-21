import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:skwer/game/game_prefs.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/game/game_rotation.dart';
import 'package:skwer/game/game_zone.dart';
import 'package:skwer/game/puzzle.dart';
import 'package:skwer/platform.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_props.dart';
import 'package:skwer/tile/skwer_tile_state.dart';

typedef SkwerTileAction = void Function(SkwerTileIndex target);

enum GameState {
  inProgress,
  clear,
  failed,
}

class Game {
  final GameProps props = GameProps();
  final List<GameRotation> rotations = [];
  final ValueNotifier<int> rotationCounter = ValueNotifier(0);

  GamePrefs prefs = GamePrefs();
  GameState state = GameState.inProgress;
  int _resetPuzzleCounter = 0;

  void resize(int numTilesX, int numTilesY) {
    clearFocus(true);
    endPuzzle(false);
    props.numTiles.value = Point(numTilesX, numTilesY);
    startPuzzle(0);
    reset(immediate: true);
  }

  void reset({
    bool recreate = false,
    int? skwer,
    bool immediate = false,
  }) {
    if (skwer != null) {
      props.skwer.value = skwer;
    }

    for (var x = 0; x < props.numTilesX; x++) {
      for (var y = 0; y < props.numTilesY; y++) {
        final index = SkwerTileIndex(x, y);
        final tileProps = props.skwerTiles[index]!;
        final state = tileProps.state;

        tileProps.isActive.value =
            props.puzzle.value?.zone.containsTile(index) ?? true;
        state.value = SkwerTileState.reset(
          state.value,
          props.skwer.value,
          immediate: immediate,
        );
        if (tileProps.isFocused.value) {
          focus(index, false);
          focus(index, true);
        }
      }
    }
    if (recreate) {
      for (final rotation in rotations) {
        rotate(rotation, false);
      }
    } else {
      rotationCounter.value = 0;
      rotations.clear();
    }
  }

  void startPuzzle(int size) {
    for (var i = 0; i < 5; i++) {
      if (i > 0) {
        reset(immediate: true);
      }
      props.puzzle.value =
          Puzzle(GameZone(props.numTilesX, props.numTilesY), size);
      final result = resetPuzzle();
      if (result) {
        return;
      }
    }
    props.isSolved.value = false;
  }

  void addToPuzzle() {
    props.puzzle.value = Puzzle.add(props.puzzle.value!);
    resetPuzzle();
  }

  void undoLastRotation() {
    if (rotations.isEmpty) {
      return;
    }

    final last = rotations.removeLast();
    rotate(
      GameRotation(index: last.index, delta: -last.delta),
      false,
    );
    rotationCounter.value += props.hasPuzzle ? last.delta : -1;
  }

  bool resetPuzzle() {
    if (!props.hasPuzzle) {
      return true;
    }

    state = GameState.inProgress;
    reset(skwer: props.skwer.value);

    final map = <SkwerTileIndex, Map<int, int>>{};
    for (final rotation in props.puzzle.value!.rotations) {
      final skwer = props.skwerTiles[rotation.index]!.state.value.skwer % 3;
      map[rotation.index] = map[rotation.index] ?? <int, int>{};
      map[rotation.index]![skwer] = (map[rotation.index]![skwer] ?? 0) + 1;
      if (map[rotation.index]![skwer]! > 2) {
        return false;
      }
      rotate(rotation);
    }

    return true;
  }

  void endPuzzle([bool shouldReset = true]) {
    props.puzzle.value = null;
    props.isSolved.value = true;
    if (shouldReset) {
      reset(skwer: props.skwer.value);
    }
  }

  void focus(SkwerTileIndex index, bool hasFocus) {
    final tileProps = props.skwerTiles[index]!;
    tileProps.isFocused.value = hasFocus;

    final highlighted = <SkwerTileIndex>{};
    if (hasFocus) {
      _skwerAction(tileProps, (target) {
        highlighted.add(target);
        props.skwerTiles[target]!.isHighlighted.value = true;
      });
    }
    for (final tile in props.skwerTiles.values) {
      if (!highlighted.contains(tile.index) && tile.isHighlighted.value) {
        tile.isHighlighted.value = false;
      }
    }
  }

  bool clearFocus([bool unfocusNode = false]) {
    for (final tile in props.skwerTiles.values) {
      if (tile.isFocused.value) {
        if (Platform.isMobile || unfocusNode) {
          tile.focusNode.unfocus();
        }
        focus(tile.index, false);
        return true;
      }
    }
    return false;
  }

  void rotateBase() {
    clearFocus();
    props.isSolved.value = true;
    reset(skwer: (props.skwer.value + 1) % 3, immediate: true);
    if (props.hasPuzzle) {
      props.isSolved.value = false;
      resetPuzzle();
    }
  }

  void rotate(GameRotation rotation, [bool addRotation = true]) {
    final tileProps = props.skwerTiles[rotation.index];
    if (tileProps == null) {
      // Maybe caused by resize, skipping this rotation.
      return;
    }

    tileProps.pressCounter.value++;

    if (state == GameState.clear && props.hasPuzzle) {
      return;
    }

    if (addRotation) {
      if (rotations.length > 1 &&
          rotations[rotations.length - 1].index == rotation.index &&
          rotations[rotations.length - 2].index == rotation.index &&
          state == GameState.failed) {
        rotations.removeLast();
        rotations.removeLast();
        rotation = GameRotation(index: rotation.index, delta: -2);
        rotationCounter.value += 2;
      } else {
        rotations.add(rotation);
        rotationCounter.value += props.hasPuzzle ? -rotation.delta : 1;
      }
    }

    _skwerAction(tileProps, (target) => _rotateTile(rotation, target));
    _checkEndGame(rotation.index);
  }

  void _skwerAction(SkwerTileProps trigger, SkwerTileAction action) {
    final skwer = trigger.state.value.skwer;
    if (skwer % 3 == 0) {
      _redAction(trigger.index, action);
    } else if (skwer % 3 == 1) {
      _greenAction(trigger.index, action);
    } else {
      _blueAction(trigger.index, action);
    }
  }

  void _redAction(SkwerTileIndex trigger, SkwerTileAction action) {
    for (var x = trigger.x - 1; x <= trigger.x + 1; x++) {
      for (var y = trigger.y - 1; y <= trigger.y + 1; y++) {
        if (x == trigger.x && y == trigger.y) {
          continue;
        }
        _clampAction(action, SkwerTileIndex(x, y));
      }
    }
  }

  void _greenAction(SkwerTileIndex trigger, SkwerTileAction action) {
    for (var x = 0; x < props.numTilesX; x++) {
      if (x == trigger.x) {
        continue;
      }
      _clampAction(action, SkwerTileIndex(x, trigger.y));
    }
    for (var y = 0; y < props.numTilesY; y++) {
      if (y == trigger.y) {
        continue;
      }
      _clampAction(action, SkwerTileIndex(trigger.x, y));
    }
  }

  void _blueAction(SkwerTileIndex trigger, SkwerTileAction action) {
    var t = 0;
    while (true) {
      t++;
      final x = _clampAction(action, trigger.translate(-t, -t)) +
          _clampAction(action, trigger.translate(t, -t)) +
          _clampAction(action, trigger.translate(-t, t)) +
          _clampAction(action, trigger.translate(t, t));
      if (x == 0) {
        return;
      }
    }
  }

  int _clampAction(SkwerTileAction action, SkwerTileIndex target) {
    if (target.x < 0 ||
        target.y < 0 ||
        target.x >= props.numTilesX ||
        target.y >= props.numTilesY) {
      return 0;
    }
    action(target);
    return 1;
  }

  void _rotateTile(
    GameRotation rotation,
    SkwerTileIndex target,
  ) {
    final state = props.skwerTiles[target]!.state;
    state.value =
        SkwerTileState.rotate(state.value, rotation.index, rotation.delta);
    if (props.skwerTiles[target]!.isFocused.value) {
      focus(target, false);
      focus(target, true);
    }
  }

  void _checkEndGame(SkwerTileIndex trigger) {
    final puzzle = props.puzzle.value;
    if (puzzle == null) {
      return;
    }

    _checkGameState();
    if (state == GameState.clear) {
      _showPuzzleWin(trigger);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (props.puzzle.value == puzzle) {
          startPuzzle(puzzle.rotations.length);
        }
      });
    } else if (state == GameState.failed) {
      final counter = ++_resetPuzzleCounter;
      Future.delayed(
        const Duration(milliseconds: 1200),
        () {
          if (counter != _resetPuzzleCounter) {
            return;
          }

          _checkGameState();
          if (state == GameState.failed) {
            resetPuzzle();
          }
        },
      );
    }
  }

  void _showPuzzleWin(SkwerTileIndex trigger) {
    clearFocus();
    props.isSolved.value = true;
  }

  void _checkGameState() {
    state = _getGameState();
  }

  GameState _getGameState() {
    var gameState = GameState.clear;
    for (var x = 0; x < props.numTilesX; x++) {
      for (var y = 0; y < props.numTilesY; y++) {
        final index = SkwerTileIndex(x, y);
        final state = props.skwerTiles[index]!.state;
        if (state.value.skwer > props.skwer.value) {
          return GameState.failed;
        } else if (state.value.skwer < props.skwer.value) {
          gameState = GameState.inProgress;
        }
      }
    }
    return gameState;
  }
}
