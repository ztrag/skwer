import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/game/game.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/tile/skwer_tile.dart';
import 'package:skwer/tile/skwer_tile_index.dart';

class GameWidget extends StatelessWidget {
  final Game game = Game();

  GameWidget({Key? key}) : super(key: key);

  GameProps get props => game.gameProps.value;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 500 || size.height < 500;
    final tileSize = min(
      min(size.height, size.width) / (isSmall ? 6 : 8),
      max(size.height, size.width) / (isSmall ? 7 : 9),
    );

    final numTilesX = (size.width / tileSize).floor();
    final numTilesY = (size.height / tileSize).floor();
    if (numTilesX != props.numTilesX || numTilesY != props.numTilesY) {
      game.resize(numTilesX, numTilesY);
    }

    return ValueListenableBuilder(
      valueListenable: game.gameProps,
      builder: (_, props, __) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            numTilesY,
            (y) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                numTilesX,
                (x) => _buildTile(x, y, tileSize),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTile(int x, int y, double tileSize) {
    final padding = EdgeInsets.all(tileSize * 0.06);
    final tileIndex = SkwerTileIndex(x, y);
    final tileProps = props.skwerTiles[tileIndex]!;
    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: Padding(
        padding: padding,
        child: MouseRegion(
          onHover: (event) => tileProps.focusNode.requestFocus(),
          child: Focus(
            focusNode: tileProps.focusNode,
            onFocusChange: (hasFocus) => game.focus(tileIndex, hasFocus),
            onKeyEvent: (_, event) {
              if (event.logicalKey == LogicalKeyboardKey.space &&
                  event is KeyDownEvent) {
                if (RawKeyboard.instance.keysPressed
                    .contains(LogicalKeyboardKey.shiftLeft)) {
                  game.reset(tileIndex);
                } else {
                  game.rotate(
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
              onTap: () => game.rotate(tileIndex, 1),
              onLongPress: () => game.reset(tileIndex),
              child: SkwerTile(props: tileProps),
            ),
          ),
        ),
      ),
    );
  }
}
