import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/menu/menu_background.dart';
import 'package:skwer/tetris/game.dart';
import 'package:skwer/tetris/game_overlay_widget.dart';
import 'package:skwer/tetris/game_panel.dart';
import 'package:skwer/tetris/game_props.dart';
import 'package:skwer/tetris/game_tile.dart';
import 'package:skwer/tile/tile_index.dart';
import 'package:skwer/util/fast_key_focus_scope.dart';

class GameWidget extends StatefulWidget {
  final VoidCallback onExit;

  const GameWidget({Key? key, required this.onExit}) : super(key: key);

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> with TickerProviderStateMixin {
  late final GameProps gameProps = GameProps(
    onStart: () => game.start(),
    onExit: widget.onExit,
  );
  late final Game game = Game(gameProps);

  late FocusScopeNode _node;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _node = FocusScopeNode();
    _ticker = Ticker(game.update);
    _ticker.start();
  }

  @override
  void reassemble() {
    super.reassemble();
    game.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _node.dispose();
    super.dispose();
  }

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
    const panelHeight = 100.0;
    final numTilesX = min((size.width / tileSize - 0.75).floor(), 10);
    final numTilesY =
        min(((size.height - panelHeight) / tileSize - 0.75).floor(), 20);

    final bottomSpace = max(
      0.0,
      min(
        panelHeight,
        size.height - (numTilesY + 0.5) * tileSize - panelHeight,
      ),
    );

    if (numTilesX != gameProps.numTilesX || numTilesY != gameProps.numTilesY) {
      game.resize(numTilesX, numTilesY);
    }

    bool isTooSmall = numTilesX < 3 || numTilesY < 5;

    return Scaffold(
      body: FastKeyFocusScope(
        autofocus: true,
        node: _node,
        onKeyEvent: game.onKeyEvent,
        controller: gameProps.keyFocusScopeController,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const MenuBackground(radius: 1.2),
            if (isTooSmall)
              const Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  'window too small',
                  style: TextStyle(color: skRed),
                  textAlign: TextAlign.center,
                ),
              ),
            if (!isTooSmall)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: tileSize * numTilesX,
                        height: panelHeight,
                        child: GamePanel(gameProps: gameProps),
                      ),
                      ValueListenableBuilder(
                        valueListenable: gameProps.numTiles,
                        builder: (_, numTiles, __) {
                          return SizedBox(
                            width: (numTiles.x + 0.5) * tileSize,
                            height: (numTiles.y + 0.5) * tileSize,
                            child: Container(
                              decoration: BoxDecoration(
                                color: skBlack,
                                border: Border.all(color: skRed, width: 2),
                              ),
                              child: Column(
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
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: bottomSpace),
                    ],
                  ),
                ],
              ),
            if (!isTooSmall)
              ListenableBuilder(
                listenable: Listenable.merge(
                    [gameProps.isGameOver, gameProps.isPaused]),
                builder: (_, __) => gameProps.isShowingOverlay
                    ? GameOverlayWidget(gameProps: gameProps)
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(int x, int y, double tileSize) {
    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: GameTile(props: gameProps.tiles[TileIndex(x, y)]!),
    );
  }
}
