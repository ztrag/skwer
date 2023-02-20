import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/game/game.dart';
import 'package:skwer/game/game_bottom_menu.dart';
import 'package:skwer/game/game_rotation.dart';
import 'package:skwer/game/game_zone.dart';
import 'package:skwer/game/help.dart';
import 'package:skwer/game/puzzle.dart';
import 'package:skwer/platform.dart';
import 'package:skwer/tile/skwer_tile.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_props.dart';

final _kDigits = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
];

class GameWidget extends StatefulWidget {
  const GameWidget({Key? key}) : super(key: key);

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final Game game = Game();
  final FocusScopeNode focusScopeNode = FocusScopeNode();

  final Map<Rect, SkwerTileProps> _positions = {};
  Future? _delayedUnfocus;
  SkwerTileIndex? _singlePointer;
  bool _isShowingHelp = false;

  @override
  void initState() {
    super.initState();
    game.prefs.numTiles.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final mediaQueryData = MediaQuery.of(context);
    final mediaSize = mediaQueryData.size;
    final size = Platform.isMobile
        ? Size(mediaSize.width, mediaSize.height - 100)
        : mediaSize;

    final numTilesFromPrefs = getNumTilesFromPrefs();
    final tileSize = getTileSize(size, numTilesFromPrefs);
    final x = (size.width / tileSize).floor();
    final y = (size.height / tileSize).floor();
    final numTilesX = numTilesFromPrefs?.x ?? (x > 9 && x % 2 == 0 ? x - 1 : x);
    final numTilesY = numTilesFromPrefs?.y ?? (y > 9 && y % 2 == 0 ? y - 1 : y);

    if (numTilesX != game.props.numTilesX ||
        numTilesY != game.props.numTilesY) {
      _positions.clear();
      game.resize(numTilesX, numTilesY);
    }

    return FocusScope(
      autofocus: true,
      node: focusScopeNode,
      onKeyEvent: _onTopKeyEvent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ValueListenableBuilder(
                  valueListenable: game.props.numTiles,
                  builder: (_, numTiles, __) => ValueListenableBuilder(
                    valueListenable: game.props.skwer,
                    builder: (_, skwer, __) => ValueListenableBuilder<Puzzle?>(
                        valueListenable: game.props.puzzle,
                        builder: (_, puzzle, __) {
                          final zone = GameZone(numTiles.x, numTiles.y);
                          final zoneSize = min(
                                zone.size.x / size.width,
                                zone.size.y / size.height,
                              ) *
                              tileSize;
                          const centerShade = [0.55, 0.65, 0.55];
                          return Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                radius: 1 - zoneSize,
                                stops: [
                                  zoneSize * 0.6,
                                  zoneSize * 0.6 + 0.3,
                                  1
                                ],
                                colors: [
                                  Color.lerp(
                                      Color.lerp(
                                        skTileColors[(skwer + 0) % 3],
                                        skTileColors[
                                            (skwer + (skwer == 0 ? 2 : 1)) % 3],
                                        0.4,
                                      )!,
                                      skBlack,
                                      centerShade[skwer % 3] *
                                          (game.props.hasPuzzle ? 0.8 : 1.4))!,
                                  Color.lerp(
                                    Color.lerp(
                                      skTileColors[(skwer + 2) % 3],
                                      skTileColors[skwer % 3],
                                      0.5,
                                    )!,
                                    skBlack,
                                    0.87,
                                  )!,
                                  Color.lerp(
                                    skTileColors[skwer % 3],
                                    skBlack,
                                    0.92,
                                  )!,
                                ],
                              ),
                            ),
                            child: puzzle == null
                                ? Container()
                                : Center(
                                    child: Container(
                                      width: zone.size.x * tileSize,
                                      height: zone.size.y * tileSize,
                                      decoration: BoxDecoration(
                                        color: skBlack,
                                        border: Border.all(
                                          width: Platform.isMobile ? 2 : 4,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                          color: Color.lerp(
                                              skTileColors[skwer % 3],
                                              skBlack,
                                              0.3)!,
                                        ),
                                      ),
                                    ),
                                  ),
                          );
                        }),
                  ),
                ),
                Listener(
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: _onPointerUp,
                  onPointerCancel: (_) => game.clearFocus(),
                  child: ValueListenableBuilder(
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
                ),
                AnimatedOpacity(
                  opacity: _isShowingHelp ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_isShowingHelp,
                    child: GestureDetector(
                      onTap: () => setState(() => _isShowingHelp = false),
                      child: Container(
                        color: skBlack.withOpacity(0.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(children: const [
                              Flexible(
                                child: Help(),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (Platform.isMobile)
            GameMenuButton(
              game: game,
              onHelp: () => setState(() {
                _isShowingHelp = !_isShowingHelp;
              }),
            ),
        ],
      ),
    );
  }

  Point<int>? getNumTilesFromPrefs() {
    if (Platform.isMobile) {
      return game.prefs.numTiles.value;
    }
    return null;
  }

  double getTileSize(Size size, Point<int>? numTilesFromPrefs) {
    if (numTilesFromPrefs == null) {
      return 75;
    }
    return min(
        size.width / numTilesFromPrefs.x, size.height / numTilesFromPrefs.y);
  }

  Widget _buildTile(int x, int y, double tileSize) {
    final padding = EdgeInsets.all(tileSize * 0.06);
    final tileIndex = SkwerTileIndex(x, y);
    final tileProps = game.props.skwerTiles[tileIndex]!;
    return SizedBox(
      key: tileProps.key,
      width: tileSize,
      height: tileSize,
      child: MouseRegion(
        onEnter: (event) {
          if (tileProps.isActive.value) {
            tileProps.focusNode.requestFocus();
            _delayedUnfocus = null;
          }
        },
        onExit: (event) {
          if (tileProps.isFocused.value) {
            _delayedUnfocus =
                Future.delayed(const Duration(milliseconds: 50), () {
              if (tileProps.isFocused.value && _delayedUnfocus != null) {
                tileProps.focusNode.unfocus();
              }
            });
          }
        },
        child: Padding(
          padding: padding,
          child: ValueListenableBuilder<Puzzle?>(
            valueListenable: game.props.puzzle,
            builder: (_, puzzle, ___) => ExcludeFocus(
              excluding: !(puzzle?.zone.containsTile(tileIndex) ?? true),
              child: Focus(
                focusNode: tileProps.focusNode,
                onFocusChange: (hasFocus) => game.focus(tileIndex, hasFocus),
                onKeyEvent: (_, event) =>
                    _onTileKeyEvent(event, tileProps, tileIndex),
                child: SkwerTile(props: tileProps, gameProps: game.props),
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _onTopKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      if (game.props.hasPuzzle) {
        game.resetPuzzle();
      } else {
        game.reset();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isShowingHelp) {
        setState(() {
          _isShowingHelp = false;
        });
        return KeyEventResult.handled;
      }

      final didClearFocus = game.clearFocus();
      if (!didClearFocus && game.props.hasPuzzle) {
        game.endPuzzle();
        return KeyEventResult.handled;
      }
      return didClearFocus ? KeyEventResult.handled : KeyEventResult.ignored;
    } else if (_kDigits.contains(event.logicalKey)) {
      final digit = _kDigits.indexOf(event.logicalKey) + 1;
      game.startPuzzle(digit);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      game.clearFocus();
      game.reset(skwer: (game.props.skwer.value + 1) % 3);
      if (game.props.hasPuzzle) {
        game.resetPuzzle();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
      setState(() {
        _isShowingHelp = !_isShowingHelp;
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onTileKeyEvent(
      KeyEvent event, SkwerTileProps tileProps, SkwerTileIndex tileIndex) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      game.rotate(GameRotation(index: tileIndex, delta: 1));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onPointerDown(PointerDownEvent event) {
    final tile = _findTileAtPosition(event.position);
    if (tile == null) {
      return;
    }

    _singlePointer = tile.index;
    _maybeEnter(tile);
  }

  void _onPointerMove(PointerMoveEvent event) {
    final tile = _findTileAtPosition(event.position);
    if (tile == null) {
      _singlePointer = null;
      game.clearFocus();
      return;
    }

    if (_singlePointer != tile.index) {
      _singlePointer = null;
    }
    _maybeEnter(tile);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (Platform.isMobile) {
      game.clearFocus();
    }

    final tile = _findTileAtPosition(event.position);
    if (tile == null) {
      return;
    }

    if (tile.isActive.value) {
      game.rotate(GameRotation(index: tile.index, delta: 1));
    }
  }

  void _maybeEnter(SkwerTileProps tile) {
    if (tile.isFocused.value) {
      return;
    }

    if (tile.isActive.value) {
      if (tile.focusNode.hasFocus) {
        game.focus(tile.index, true);
      } else {
        tile.focusNode.requestFocus();
      }
    } else {
      game.clearFocus();
    }
  }

  void _initPositions() {
    if (_positions.isNotEmpty) {
      return;
    }

    for (final tile in game.props.skwerTiles.values) {
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

  SkwerTileProps? _findTileAtPosition(Offset position) {
    _initPositions();
    for (final tile in _positions.entries) {
      if (tile.key.contains(position)) {
        return tile.value;
      }
    }

    return null;
  }
}
