import 'package:flutter/cupertino.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_state.dart';

class Game {
  final ValueNotifier<GameProps> gameProps = ValueNotifier(GameProps());

  GameProps get props => gameProps.value;

  void resize(int numTilesX, int numTilesY) {
    gameProps.value = GameProps.resize(
      props: gameProps.value,
      numTilesX: numTilesX,
      numTilesY: numTilesY,
    );
    Future.microtask(() {
      final trigger = SkwerTileIndex(numTilesX ~/ 2, numTilesY ~/ 2);
      reset(trigger);
      props.skwerTiles[trigger]!.focusNode.requestFocus();
    });
  }

  void focus(SkwerTileIndex index, bool hasFocus) {
    final tileProps = props.skwerTiles[index]!;
    if (tileProps.state.value.hasFocus != hasFocus) {
      tileProps.state.value =
          SkwerTileState.onFocus(tileProps.state.value, hasFocus);
    }
  }

  void reset(SkwerTileIndex trigger) {
    final tileProps = props.skwerTiles[trigger]!;

    final skwer = tileProps.state.value.skwer % 3;
    for (var x = 0; x < props.numTilesX; x++) {
      for (var y = 0; y < props.numTilesY; y++) {
        final index = SkwerTileIndex(x, y);
        final state = props.skwerTiles[index]!.state;
        state.value = SkwerTileState.reset(
          state.value,
          trigger,
          skwer,
        );
      }
    }
  }

  void rotate(SkwerTileIndex index, int dir) {
    final tileProps = props.skwerTiles[index]!;
    final tileState = tileProps.state;
    tileState.value = SkwerTileState.onPress(tileState.value);

    final skwer = tileProps.state.value.skwer;
    if (skwer % 3 == 0) {
      _rotateRed(index, dir);
    } else if (skwer % 3 == 1) {
      _rotateGreen(index, dir);
    } else {
      _rotateBlue(index, dir);
    }
  }

  void _rotateRed(SkwerTileIndex trigger, int dir) {
    for (var x = trigger.x - 1; x <= trigger.x + 1; x++) {
      for (var y = trigger.y - 1; y <= trigger.y + 1; y++) {
        if (x == trigger.x && y == trigger.y) {
          continue;
        }
        _maybeRotateTile(trigger, SkwerTileIndex(x, y), dir);
      }
    }
  }

  void _rotateBlue(SkwerTileIndex trigger, int dir) {
    var t = 0;
    while (true) {
      t++;
      final x = _maybeRotateTile(trigger, trigger.translate(-t, -t), dir) +
          _maybeRotateTile(trigger, trigger.translate(t, -t), dir) +
          _maybeRotateTile(trigger, trigger.translate(-t, t), dir) +
          _maybeRotateTile(trigger, trigger.translate(t, t), dir);
      if (x == 0) {
        return;
      }
    }
  }

  void _rotateGreen(SkwerTileIndex trigger, int dir) {
    for (var x = 0; x < props.numTilesX; x++) {
      if (x == trigger.x) {
        continue;
      }
      _maybeRotateTile(trigger, SkwerTileIndex(x, trigger.y), dir);
    }
    for (var y = 0; y < props.numTilesY; y++) {
      if (y == trigger.y) {
        continue;
      }
      _maybeRotateTile(trigger, SkwerTileIndex(trigger.x, y), dir);
    }
  }

  int _maybeRotateTile(
    SkwerTileIndex trigger,
    SkwerTileIndex target,
    int delta,
  ) {
    if (target.x < 0 ||
        target.y < 0 ||
        target.x >= props.numTilesX ||
        target.y >= props.numTilesY) {
      return 0;
    }
    final state = props.skwerTiles[target]!.state;
    state.value = SkwerTileState.rotate(state.value, trigger, delta);
    return 1;
  }
}
