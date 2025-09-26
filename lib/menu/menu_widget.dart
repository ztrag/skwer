import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/games.dart';
import 'package:skwer/menu/menu.dart';
import 'package:skwer/menu/menu_background.dart';
import 'package:skwer/menu/menu_tile.dart';
import 'package:skwer/platform.dart';
import 'package:skwer/util/command_line.dart';
import 'package:skwer/util/fast_key_focus.dart';
import 'package:skwer/util/move_arrows.dart';

class MenuWidget extends StatefulWidget {
  final ValueNotifier<Games?> menuSelection;

  const MenuWidget({Key? key, required this.menuSelection}) : super(key: key);

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  final Menu menu = Menu();
  final FocusScopeNode focusScopeNode = FocusScopeNode();
  late final CommandLineController commandLineController =
      CommandLineController(
    Games.values
        .map((game) =>
            Command(game.name, () => widget.menuSelection.value = game))
        .toList(),
  );

  Point<int>? bgAnchor;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      body: LayoutBuilder(
        builder: (c, constraints) {
          final size = constraints.biggest;

          const minNumTiles = Point(13, 13);
          final tileSize = _getTileSize(size, minNumTiles);
          final x = (size.width / tileSize).floor();
          final y = (size.height / tileSize).floor();
          final numTilesX = x;
          final numTilesY = y;

          if (numTilesX != menu.props.numTilesX ||
              numTilesY != menu.props.numTilesY) {
            menu.props.numTiles.value = Point(numTilesX, numTilesY);
            Future.delayed(
              const Duration(milliseconds: 300),
              () async {
                if (!mounted) {
                  return;
                }
                menu.drawWelcome();
              },
            );
          }

          return FastKeyFocusScope(
            autofocus: true,
            node: focusScopeNode,
            onKeyEvent: _onKeyEvent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const MenuBackground(),
                      ValueListenableBuilder(
                        valueListenable: menu.props.numTiles,
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
                      Positioned(
                        left: Platform.isMobile ? null : 20,
                        top: Platform.isMobile ? null : 20,
                        right: Platform.isMobile ? 20 : null,
                        bottom: Platform.isMobile ? 20 : null,
                        child: CommandLine(controller: commandLineController),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _getTileSize(Size size, Point<int> numTiles) {
    return min(size.width / numTiles.x, size.height / numTiles.y);
  }

  Widget _buildTile(int x, int y, double tileSize) {
    final tileIndex = Point(x, y);
    final tileProps = menu.props.tiles[tileIndex]!;
    return SizedBox(
      key: tileProps.key,
      width: tileSize,
      height: tileSize,
      child: MenuTile(
        props: tileProps,
        gameProps: menu.props,
      ),
    );
  }

  KeyEventResult _onKeyEvent(FastKeyEvent event) {
    final dir = MoveArrows.getDir(event);
    if (dir != null) {
      menu.props.bgAnchor = Point(
        (menu.props.bgAnchor.x + dir.x) % menu.props.numTilesX,
        (menu.props.bgAnchor.y + dir.y) % menu.props.numTilesY,
      );
      menu.drawWelcome();
    }
    return commandLineController.onKeyEvent(event);
  }
}
