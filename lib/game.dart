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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tileSize = min(
      min(size.height, size.width) / 8.0,
      max(size.height, size.width) / 9.0,
    );
    final padding = EdgeInsets.all(tileSize * 0.06);

    final numTilesX = (size.width / tileSize).floor();
    final numTilesY = (size.height / tileSize).floor();

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
    // FIXME use skwer rules
    final props = skwerTiles[index]!;
    props.state.value = SkwerTileState.addCount(props.state.value, 1);
  }
}
