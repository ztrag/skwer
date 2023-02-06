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
                                  .contains(LogicalKeyboardKey.shiftLeft) ||
                              RawKeyboard.instance.keysPressed
                                  .contains(LogicalKeyboardKey.shiftRight)) {
                            _onResetFromTile(tileIndex);
                          } else {
                            _onPressTile(tileIndex);
                          }
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: GestureDetector(
                        onTap: () => _onPressTile(tileIndex),
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

  void _onPressTile(SkwerTileIndex index) {
    final props = skwerTiles[index]!;

    final state = props.state;
    state.value = SkwerTileState.onFocus(state.value, false);
    state.value = SkwerTileState.addCount(state.value, props.key.value, 0);

    final count = props.state.value.count;
    if (count % 3 == 0) {
      for (var x = index.x - 1; x <= index.x + 1; x++) {
        for (var y = index.y - 1; y <= index.y + 1; y++) {
          if (x == index.x && y == index.y) {
            continue;
          }
          _maybeRotateTile(index, SkwerTileIndex(x, y));
        }
      }
    } else if (count % 3 == 1) {
      for (var x = 0; x < numTilesX; x++) {
        if (x == index.x) {
          continue;
        }
        _maybeRotateTile(index, SkwerTileIndex(x, index.y));
      }
      for (var y = 0; y < numTilesY; y++) {
        if (y == index.y) {
          continue;
        }
        _maybeRotateTile(index, SkwerTileIndex(index.x, y));
      }
    } else {
      var i = 0;
      var stillHas = true;
      while (stillHas) {
        i++;
        final changes = _maybeRotateTile(
                index, SkwerTileIndex(index.x - i, index.y - i)) +
            _maybeRotateTile(index, SkwerTileIndex(index.x + i, index.y - i)) +
            _maybeRotateTile(index, SkwerTileIndex(index.x - i, index.y + i)) +
            _maybeRotateTile(index, SkwerTileIndex(index.x + i, index.y + i));
        stillHas = changes > 0;
      }
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

  int _maybeRotateTile(SkwerTileIndex trigger, SkwerTileIndex target) {
    if (target.x < 0 ||
        target.y < 0 ||
        target.x >= numTilesX ||
        target.y >= numTilesY) {
      return 0;
    }
    final state = skwerTiles[target]!.state;
    state.value = SkwerTileState.addCount(state.value, trigger, 1);
    return 1;
  }
}
