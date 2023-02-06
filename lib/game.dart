import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/skwer_tile.dart';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final Map<SkwerTileIndex, SkwerTileProps> skwerTiles =
      <SkwerTileIndex, SkwerTileProps>{};
  int numTilesX = 0;
  int numTilesY = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      _onResetFromTile(SkwerTileIndex(numTilesX ~/ 2, numTilesY ~/ 2));
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tileSize = min(
      min(size.height, size.width) / 8.0,
      max(size.height, size.width) / 9.0,
    );
    final padding = EdgeInsets.all(tileSize * 0.06);

    numTilesX = (size.width / tileSize).floor();
    numTilesY = (size.height / tileSize).floor();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        numTilesY,
        (j) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            numTilesX,
            (i) {
              final tileIndex = SkwerTileIndex(i, j);
              final tileProps =
                  skwerTiles[tileIndex] ?? SkwerTileProps(tileIndex: tileIndex);
              skwerTiles[tileIndex] = tileProps;

              return SizedBox(
                width: tileSize,
                height: tileSize,
                child: Padding(
                  padding: padding,
                  child: MouseRegion(
                    onHover: (event) => tileProps.focusNode.requestFocus(),
                    child: Focus(
                      focusNode: tileProps.focusNode,
                      onFocusChange: (hasFocus) =>
                          _onFocusTile(tileIndex, hasFocus),
                      onKeyEvent: (_, event) {
                        if (event.logicalKey == LogicalKeyboardKey.space &&
                            event is KeyDownEvent) {
                          if (RawKeyboard.instance.keysPressed
                              .contains(LogicalKeyboardKey.shiftLeft)) {
                            _onResetFromTile(tileIndex);
                          } else {
                            _onPressTile(
                                tileIndex,
                                RawKeyboard.instance.keysPressed
                                        .contains(LogicalKeyboardKey.shiftRight)
                                    ? -1
                                    : 1);
                          }
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: GestureDetector(
                        onTap: () => _onPressTile(tileIndex, 1),
                        onLongPress: () => _onResetFromTile(tileIndex),
                        child: SkwerTile(props: tileProps),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onFocusTile(SkwerTileIndex index, bool hasFocus) {
    final props = skwerTiles[index]!;
    if (props.state.value.hasFocus != hasFocus) {
      props.state.value = SkwerTileState.onFocus(props.state.value, hasFocus);
    }
  }

  void _onPressTile(SkwerTileIndex index, int dir) {
    final props = skwerTiles[index]!;

    final state = props.state;
    state.value = SkwerTileState.onFocus(state.value, false);
    state.value = SkwerTileState.addCount(state.value, props.key.value, 0);

    final count = props.state.value.count;
    if (count % 3 == 0) {
      _rotateRed(index, dir);
    } else if (count % 3 == 1) {
      _rotateGreen(index, dir);
    } else {
      _rotateBlue(index, dir);
    }
  }

  void _onResetFromTile(SkwerTileIndex index) {
    final props = skwerTiles[index]!;

    final count = props.state.value.count % 3;
    for (var x = 0; x < numTilesX; x++) {
      for (var y = 0; y < numTilesY; y++) {
        final state = skwerTiles[SkwerTileIndex(x, y)]!.state;
        state.value = SkwerTileState.addCount(
          state.value,
          index,
          count - state.value.count,
        );
      }
    }
  }

  int _maybeRotateTile(
    SkwerTileIndex trigger,
    SkwerTileIndex target,
    int delta,
  ) {
    if (target.x < 0 ||
        target.y < 0 ||
        target.x >= numTilesX ||
        target.y >= numTilesY) {
      return 0;
    }
    final state = skwerTiles[target]!.state;
    state.value = SkwerTileState.addCount(state.value, trigger, delta);
    return 1;
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
    for (var x = 0; x < numTilesX; x++) {
      if (x == trigger.x) {
        continue;
      }
      _maybeRotateTile(trigger, SkwerTileIndex(x, trigger.y), dir);
    }
    for (var y = 0; y < numTilesY; y++) {
      if (y == trigger.y) {
        continue;
      }
      _maybeRotateTile(trigger, SkwerTileIndex(trigger.x, y), dir);
    }
  }
}
