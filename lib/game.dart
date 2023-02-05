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
                          _onPressTile(tileIndex);
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: GestureDetector(
                        onTap: () => _onPressTile(tileIndex),
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
    // FIXME highlight skwer rules
    final props = skwerTiles[index]!;
    props.state.value = SkwerTileState.onFocus(props.state.value, hasFocus);
  }

  void _onPressTile(SkwerTileIndex index) {
    final props = skwerTiles[index]!;

    final count = props.state.value.count;
    if (count % 3 == 0) {
      for (var x = index.x - 1; x <= index.x + 1; x++) {
        for (var y = index.y - 1; y <= index.y + 1; y++) {
          if (x == index.x && y == index.y) {
            continue;
          }
          _maybeRotateTile(SkwerTileIndex(x, y));
        }
      }
    } else if (count % 3 == 1) {
      for (var x = 0; x < numTilesX; x++) {
        if (x == index.x) {
          continue;
        }
        _maybeRotateTile(SkwerTileIndex(x, index.y));
      }
      for (var y = 0; y < numTilesY; y++) {
        if (y == index.y) {
          continue;
        }
        _maybeRotateTile(SkwerTileIndex(index.x, y));
      }
    } else {
      var i = 0;
      var stillHas = true;
      while (stillHas) {
        i++;
        final changes =
            _maybeRotateTile(SkwerTileIndex(index.x - i, index.y - i)) +
                _maybeRotateTile(SkwerTileIndex(index.x + i, index.y - i)) +
                _maybeRotateTile(SkwerTileIndex(index.x - i, index.y + i)) +
                _maybeRotateTile(SkwerTileIndex(index.x + i, index.y + i));
        stillHas = changes > 0;
      }
    }
  }

  int _maybeRotateTile(SkwerTileIndex index) {
    if (index.x < 0 ||
        index.y < 0 ||
        index.x >= numTilesX ||
        index.y >= numTilesY) {
      return 0;
    }
    final state = skwerTiles[index]!.state;
    state.value = SkwerTileState.addCount(state.value, 1);
    return 1;
  }
}
