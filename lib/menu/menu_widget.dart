import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/games.dart';
import 'package:skwer/menu/menu.dart';
import 'package:skwer/menu/menu_background.dart';
import 'package:skwer/menu/menu_tile.dart';
import 'package:skwer/menu/menu_tile_props.dart';
import 'package:skwer/util/command_line.dart';
import 'package:skwer/util/fast_key_focus_scope.dart';

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

  final Map<Rect, MenuTileProps> _positions = {};

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
            _positions.clear();
            menu.props.numTiles.value = Point(numTilesX, numTilesY);
            Future.delayed(
              const Duration(milliseconds: 300),
              () => menu.drawWelcome(),
            );
          }

          return FastKeyFocusScope(
            autofocus: true,
            node: focusScopeNode,
            onKeyEvent: commandLineController.onKeyEvent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const MenuBackground(),
                      Listener(
                        onPointerDown: _onPointerDown,
                        onPointerMove: _onPointerMove,
                        onPointerUp: _onPointerUp,
                        child: ValueListenableBuilder(
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
                      ),
                      Positioned(
                        left: 20,
                        top: 20,
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
      child: MouseRegion(
        onEnter: (event) => tileProps.focusNode.requestFocus(),
        onHover: (event) {
          if (!tileProps.isFocused.value && tileProps.focusNode.hasFocus) {
            tileProps.isFocused.value = true;
          }
        },
        child: Focus(
          focusNode: tileProps.focusNode,
          onFocusChange: (hasFocus) {
            menu.drawWelcome(tileProps.index);
            // tileProps.isFocused.value = hasFocus;
          },
          child: MenuTile(
            props: tileProps,
            gameProps: menu.props,
          ),
        ),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    final tile = _findTileAtPosition(event.position);
    if (tile == null) {
      return;
    }

    _maybeEnter(tile.value, tile.key, event.position);
  }

  void _onPointerMove(PointerMoveEvent event) {
    final tile = _findTileAtPosition(event.position);
    if (tile == null) {
      return;
    }

    _maybeEnter(tile.value, tile.key, event.position);
  }

  void _onPointerUp(PointerUpEvent event) {
    final tile = _findTileAtPosition(event.position);
    if (tile == null) {
      return;
    }

    // TODO color
  }

  void _maybeEnter(MenuTileProps tile, Rect rect, Offset position) {
    tile.hoverPosition.value = position - rect.topLeft;
    if (tile.isFocused.value) {
      return;
    }

    if (tile.focusNode.hasFocus) {
      tile.isFocused.value = true;
    } else {
      tile.focusNode.requestFocus();
    }
  }

  void _initPositions() {
    if (_positions.isNotEmpty) {
      return;
    }

    for (final tile in menu.props.tiles.values) {
      final box = tile.key.currentContext?.findRenderObject() as RenderBox;
      final start = box.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(
        start.dx,
        start.dy,
        box.size.width,
        box.size.height,
      );
      _positions.addAll({rect: tile});
    }
  }

  MapEntry<Rect, MenuTileProps>? _findTileAtPosition(Offset position) {
    _initPositions();
    for (final tile in _positions.entries) {
      if (tile.key.contains(position)) {
        return tile;
      }
    }

    return null;
  }
}
