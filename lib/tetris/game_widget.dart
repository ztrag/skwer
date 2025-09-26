import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/menu/menu_background.dart';
import 'package:skwer/platform.dart';
import 'package:skwer/tetris/game.dart';
import 'package:skwer/tetris/game_bottom_menu.dart';
import 'package:skwer/tetris/game_overlay_widget.dart';
import 'package:skwer/tetris/game_panel.dart';
import 'package:skwer/tetris/game_props.dart';
import 'package:skwer/tetris/game_tile.dart';
import 'package:skwer/tile/tile_index.dart';
import 'package:skwer/util/fast_key_focus.dart';
import 'package:skwer/util/touch_arrows.dart';

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

  late final AnimationController _boardSizeHintController = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  );
  late final Animation<double> _boardSizeHintAnimation =
      CurveTween(curve: Curves.ease).animate(_boardSizeHintController);

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
    _boardSizeHintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: game.props.prefs.boardSize,
        builder: (_, boardSize, __) {
          return LayoutBuilder(builder: (context, constraints) {
            final bottomMenuHeight = Platform.isMobile ? 64.0 : 16.0;
            const topPanelHeight = 100.0;
            final size = Size(
              constraints.maxWidth - 16,
              constraints.maxHeight - bottomMenuHeight - topPanelHeight,
            );
            gameProps.size.value = size;

            final numTilesX = Platform.isMobile || size.width > 400
                ? boardSize
                : size.width * (boardSize + 0.75) ~/ 400;
            final int numTilesY;
            final int tileSize;

            if (Platform.isMobile || size.width < 400) {
              tileSize = size.width ~/ (numTilesX + 0.75);
              numTilesY = min(20, (size.height / tileSize - 0.75).floor());
            } else {
              final tileSizeMinX = 400 ~/ (numTilesX + 0.75);
              final expansionSize =
                  max(0.0, size.height - tileSizeMinX * 20.75);
              numTilesY = min(20, (size.height / tileSizeMinX - 0.75).floor());
              tileSize = min(
                (size.height - min(expansionSize, topPanelHeight)) ~/
                    (numTilesY + 0.75),
                size.width ~/ (numTilesX + 0.75),
              );
            }

            if (numTilesX != gameProps.numTilesX ||
                numTilesY != gameProps.numTilesY) {
              _boardSizeHintController.forward(from: 0.0);
              game.resize(numTilesX, numTilesY);
            }

            final isTooSmall = numTilesX < 3 || numTilesY < 5;

            return FastKeyFocusScope(
              autofocus: true,
              node: _node,
              onKeyEvent: game.onKeyEvent,
              controller: gameProps.keyFocusScopeController,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: gameProps.level,
                    builder: (_, level, __) => MenuBackground(
                      radius: 0.8,
                      color: level.gradientColor,
                    ),
                  ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(child: SizedBox.shrink()),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 1.0 * tileSize * numTilesX,
                                  height: topPanelHeight,
                                  child: GamePanel(gameProps: gameProps),
                                ),
                                TouchArrows(
                                  controller: gameProps.touchArrowsController,
                                  size: Size(
                                    1.0 * tileSize * numTilesX,
                                    1.0 * tileSize * numTilesY,
                                  ),
                                  onTouchEvent: game.onTouchArrowEvent,
                                  child: ValueListenableBuilder(
                                    valueListenable: gameProps.numTiles,
                                    builder: (_, numTiles, __) {
                                      return SizedBox(
                                        width: (numTiles.x + 0.5) * tileSize,
                                        height: (numTiles.y + 0.5) * tileSize,
                                        child: ValueListenableBuilder(
                                          valueListenable: gameProps.level,
                                          builder: (_, level, child) =>
                                              Container(
                                            decoration: BoxDecoration(
                                              color: skBlack,
                                              border: Border.all(
                                                color: level.borderColor,
                                                width: 2,
                                              ),
                                            ),
                                            child: child,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                              numTiles.y,
                                              (y) => Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: List.generate(
                                                  numTiles.x,
                                                  (x) => _buildTile(
                                                      x, y, tileSize),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const Expanded(child: SizedBox.shrink()),
                            if (Platform.isMobile) ...[
                              GameBottomMenu(
                                game: game,
                                onHelp: () => setState(() {
                                  game.props.isPaused.value =
                                      !game.props.isPaused.value;
                                }),
                              )
                            ],
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
            );
          });
        },
      ),
    );
  }

  Widget _buildTile(int x, int y, int tileSize) {
    return SizedBox(
      width: 1.0 * tileSize,
      height: 1.0 * tileSize,
      child: GameTile(
        props: gameProps.tiles[TileIndex(x, y)]!,
        boardSizeAnimation: _boardSizeHintAnimation,
      ),
    );
  }
}
