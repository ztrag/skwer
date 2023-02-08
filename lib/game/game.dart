import 'package:flutter/cupertino.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/game/game_rotation.dart';
import 'package:skwer/game/game_zone.dart';
import 'package:skwer/game/puzzle.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_state.dart';

class Game {
  final ValueNotifier<GameProps> gameProps = ValueNotifier(GameProps());
  final List<GameRotation> rotations = [];

  GameProps get props => gameProps.value;

  void resize(int numTilesX, int numTilesY) {
    gameProps.value = GameProps.resize(
      props: gameProps.value,
      numTilesX: numTilesX,
      numTilesY: numTilesY,
    );
    Future.microtask(() {
      reset(recreate: true);
    });
  }

  void reset({
    SkwerTileIndex? trigger,
    bool recreate = false,
    bool reSkwer = false,
  }) {
    if (reSkwer) {
      gameProps.value = GameProps.reSkwer(
        props: props,
        skwer: props.skwerTiles[trigger]!.state.value.skwer % 3,
      );
      props.puzzle.value = null;
    }

    final skwer = props.skwer % 3;
    for (var x = 0; x < props.numTilesX; x++) {
      for (var y = 0; y < props.numTilesY; y++) {
        final index = SkwerTileIndex(x, y);
        final state = props.skwerTiles[index]!.state;
        state.value = SkwerTileState.reset(
          state.value,
          skwer,
          trigger: trigger,
          isActive: props.puzzle.value?.zone.containsTile(index) ?? true,
          hasPuzzle: props.puzzle.value != null,
        );
      }
    }
    if (recreate) {
      for (final rotation in rotations) {
        rotate(rotation, false);
      }
    } else {
      rotations.clear();
    }
  }

  void startPuzzle(int size) {
    props.puzzle.value =
        Puzzle(GameZone(props.numTilesX, props.numTilesY), size);
    resetPuzzle();
  }

  void resetPuzzle() {
    reset(trigger: props.puzzle.value!.rotations.last.index);
    for (final rotation in props.puzzle.value!.rotations) {
      rotate(rotation);
    }
  }

  void focus(SkwerTileIndex index, bool hasFocus) {
    final tileProps = props.skwerTiles[index]!;
    if (tileProps.state.value.hasFocus != hasFocus) {
      tileProps.state.value =
          SkwerTileState.onFocus(tileProps.state.value, hasFocus);
    }
  }

  void rotate(GameRotation rotation, [bool addRotation = true]) {
    final tileProps = props.skwerTiles[rotation.index];
    if (tileProps == null) {
      // Maybe caused by resize, skipping this rotation.
      return;
    }

    if (addRotation) {
      rotations.add(rotation);
    }

    final tileState = tileProps.state;
    tileState.value = SkwerTileState.onPress(tileState.value);

    final skwer = tileProps.state.value.skwer;
    if (skwer % 3 == 0) {
      _rotateRed(rotation);
    } else if (skwer % 3 == 1) {
      _rotateGreen(rotation);
    } else {
      _rotateBlue(rotation);
    }

    _checkEndGame(rotation.index);
  }

  void _rotateRed(GameRotation rotation) {
    final trigger = rotation.index;

    for (var x = trigger.x - 1; x <= trigger.x + 1; x++) {
      for (var y = trigger.y - 1; y <= trigger.y + 1; y++) {
        if (x == trigger.x && y == trigger.y) {
          continue;
        }
        _maybeRotateTile(rotation, SkwerTileIndex(x, y));
      }
    }
  }

  void _rotateBlue(GameRotation rotation) {
    final trigger = rotation.index;

    var t = 0;
    while (true) {
      t++;
      final x = _maybeRotateTile(rotation, trigger.translate(-t, -t)) +
          _maybeRotateTile(rotation, trigger.translate(t, -t)) +
          _maybeRotateTile(rotation, trigger.translate(-t, t)) +
          _maybeRotateTile(rotation, trigger.translate(t, t));
      if (x == 0) {
        return;
      }
    }
  }

  void _rotateGreen(GameRotation rotation) {
    final trigger = rotation.index;

    for (var x = 0; x < props.numTilesX; x++) {
      if (x == trigger.x) {
        continue;
      }
      _maybeRotateTile(rotation, SkwerTileIndex(x, trigger.y));
    }
    for (var y = 0; y < props.numTilesY; y++) {
      if (y == trigger.y) {
        continue;
      }
      _maybeRotateTile(rotation, SkwerTileIndex(trigger.x, y));
    }
  }

  int _maybeRotateTile(
    GameRotation rotation,
    SkwerTileIndex target,
  ) {
    if (target.x < 0 ||
        target.y < 0 ||
        target.x >= props.numTilesX ||
        target.y >= props.numTilesY) {
      return 0;
    }

    final state = props.skwerTiles[target]!.state;
    state.value =
        SkwerTileState.rotate(state.value, rotation.index, rotation.delta);
    return 1;
  }

  void _checkEndGame(SkwerTileIndex trigger) {
    if (props.puzzle.value == null || !_isClearState()) {
      return;
    }

    final puzzleSize = props.puzzle.value!.rotations.length;
    _showPuzzleWin(trigger);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_isClearState()) {
        startPuzzle(puzzleSize);
      }
    });
  }

  void _showPuzzleWin(SkwerTileIndex trigger) {
    for (var x = 0; x < props.numTilesX; x++) {
      for (var y = 0; y < props.numTilesY; y++) {
        final index = SkwerTileIndex(x, y);
        final state = props.skwerTiles[index]!.state;
        state.value = SkwerTileState.reset(
          state.value,
          props.skwer,
          trigger: trigger,
          isSolved: true,
          hasPuzzle: true,
        );
      }
    }
  }

  bool _isClearState() {
    for (var x = 0; x < props.numTilesX; x++) {
      for (var y = 0; y < props.numTilesY; y++) {
        final index = SkwerTileIndex(x, y);
        final state = props.skwerTiles[index]!.state;
        if (state.value.skwer % 3 != props.skwer) {
          return false;
        }
      }
    }
    return true;
  }
}
