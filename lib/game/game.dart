import 'package:flutter/cupertino.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/game/game_rotation.dart';
import 'package:skwer/game/game_zone.dart';
import 'package:skwer/game/puzzle.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_props.dart';
import 'package:skwer/tile/skwer_tile_state.dart';

typedef SkwerTileAction = void Function(SkwerTileIndex target);

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
          trigger: reSkwer ? trigger : null,
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
    if (props.puzzle.value == null) {
      return;
    }

    reset(trigger: props.puzzle.value!.rotations.last.index);
    for (final rotation in props.puzzle.value!.rotations) {
      rotate(rotation);
    }
  }

  void focus(SkwerTileIndex index, bool hasFocus) {
    final tileProps = props.skwerTiles[index]!;
    tileProps.state.value =
        SkwerTileState.onFocus(tileProps.state.value, hasFocus);

    final highlighted = <SkwerTileIndex>{};
    if (hasFocus) {
      _skwerAction(tileProps, (target) {
        highlighted.add(target);
        final state = props.skwerTiles[target]!.state;
        state.value = SkwerTileState.onHighlight(state.value, true);
      });
    }
    for (final tile in props.skwerTiles.values) {
      if (!highlighted.contains(tile.index) && tile.state.value.isHighlighted) {
        final state = tile.state;
        state.value = SkwerTileState.onHighlight(state.value, false);
      }
    }
  }

  bool clearFocus() {
    for (final tile in props.skwerTiles.values) {
      if (tile.state.value.hasFocus) {
        focus(tile.index, false);
        return true;
      }
    }
    return false;
  }

  void rotate(GameRotation rotation, [bool addRotation = true]) {
    final tileProps = props.skwerTiles[rotation.index];
    if (tileProps == null) {
      // Maybe caused by resize, skipping this rotation.
      return;
    }
    final tileState = tileProps.state;
    tileState.value = SkwerTileState.onPress(tileState.value);

    if (addRotation) {
      rotations.add(rotation);
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
    if (state.value.hasFocus) {
      focus(target, true);
    }
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
    clearFocus();
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
