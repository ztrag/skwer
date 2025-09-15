import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/tetris/game.dart';
import 'package:skwer/tetris/game_tile.dart';
import 'package:skwer/tile/tile_index.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({Key? key}) : super(key: key);

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final Game game = Game();
  final FocusScopeNode focusScopeNode = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final mediaQueryData = MediaQuery.of(context);
    final mediaSize = mediaQueryData.size;
    final size = Size(mediaSize.width, mediaSize.height);

    const tileSize = 40.0;
    final numTilesX = (size.width / tileSize).floor();
    final numTilesY = (size.height / tileSize).floor();

    if (numTilesX != game.props.numTilesX ||
        numTilesY != game.props.numTilesY) {
      game.resize(min(numTilesX, 10), min(numTilesY, 20));
    }

    return FocusScope(
      autofocus: true,
      node: focusScopeNode,
      onKeyEvent: _onTopKeyEvent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ValueListenableBuilder(
            valueListenable: game.props.numTiles,
            builder: (_, numTiles, __) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  numTiles.y,
                  (y) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      numTiles.x,
                      (x) => _buildTile(x, y, tileSize),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  KeyEventResult _onTopKeyEvent(FocusNode node, KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
        event is! KeyUpEvent) {
      game.props.rotateTetramino();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildTile(int x, int y, double tileSize) {
    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: GameTile(props: game.props.tiles[TileIndex(x, y)]!),
    );
  }
}
