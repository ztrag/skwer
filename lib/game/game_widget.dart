import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/game/game.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/game/game_rotation.dart';
import 'package:skwer/game/game_zone.dart';
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
  LogicalKeyboardKey.digit0,
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

  GameProps get props => game.gameProps.value;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final mediaQueryData = MediaQuery.of(context);
    final mediaSize = mediaQueryData.size;
    final size = Platform.isMobile
        ? Size(mediaSize.width, mediaSize.height - 150)
        : mediaSize;
    const tileSize = 80.0;

    final x = (size.width / tileSize).floor();
    final y = (size.height / tileSize).floor();
    final numTilesX = x > 9 && x % 2 == 0 ? x - 1 : x;
    final numTilesY = y > 9 && y % 2 == 0 ? y - 1 : y;
    if (numTilesX != props.numTilesX || numTilesY != props.numTilesY) {
      _positions.clear();
      game.resize(numTilesX, numTilesY);
    }

    return FocusScope(
      autofocus: true,
      node: focusScopeNode,
      onKeyEvent: _onTopKeyEvent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ValueListenableBuilder(
            valueListenable: game.gameProps,
            builder: (_, props, __) => ValueListenableBuilder<Puzzle?>(
                valueListenable: game.gameProps.value.puzzle,
                builder: (_, puzzle, __) {
                  final zone = GameZone(props.numTilesX, props.numTilesY);
                  final skwer = game.gameProps.value.skwer;
                  final zoneSize = min(
                        zone.size.x / size.width,
                        zone.size.y / size.height,
                      ) *
                      tileSize;
                  const centerShade = [0.55, 0.65, 0.55];
                  return Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 1 - zoneSize,
                          stops: [zoneSize * 0.6, zoneSize * 0.6 + 0.3, 1],
                          colors: [
                            Color.lerp(
                                Color.lerp(
                                  skTileColors[(skwer + 0) % 3],
                                  skTileColors[
                                      (skwer + (skwer == 0 ? 2 : 1)) % 3],
                                  0.4,
                                )!,
                                skBlack,
                                centerShade[skwer % 3])!,
                            Color.lerp(
                              Color.lerp(
                                skTileColors[(skwer + 2) % 3],
                                skTileColors[skwer % 3],
                                0.5,
                              )!,
                              skBlack,
                              0.8,
                            )!,
                            Color.lerp(
                              skTileColors[skwer % 3],
                              skBlack,
                              0.8,
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
                                    width: 4,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    color: Color.lerp(
                                        skTileColors[
                                            game.gameProps.value.skwer % 3],
                                        skBlack,
                                        0.3)!,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  );
                }),
          ),
          Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: (_) => game.clearFocus(),
            child: ValueListenableBuilder(
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
            ),
          ),
          if (Platform.isMobile)
            Positioned(
              bottom: 0,
              right: 0,
              child: ValueListenableBuilder(
                valueListenable: game.gameProps,
                builder: (_, props, __) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onLongPress: () {
                        game.props.puzzle.value = null;
                        game.reset(skwer: (game.gameProps.value.skwer + 1) % 3);
                      },
                      onTap: () {
                        if (game.props.puzzle.value == null) {
                          game.startPuzzle(1);
                        } else {
                          if (game.rotations.length ==
                              game.props.puzzle.value!.rotations.length) {
                            game.startPuzzle((game.rotations.length + 1) % 8);
                          }
                          game.resetPuzzle();
                        }
                      },
                      child: Opacity(
                        opacity: 0.5,
                        child: Container(
                          color: skWhite.withOpacity(0.3),
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Container(
                              color: skTileColors[(props.skwer + 2) % 3],
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Container(
                                  color: skTileColors[(props.skwer + 1) % 3],
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Container(
                                      color: skTileColors[props.skwer % 3],
                                      child: const SizedBox(
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
    );
  }

  Widget _buildTile(int x, int y, double tileSize) {
    final padding = EdgeInsets.all(tileSize * 0.06);
    final tileIndex = SkwerTileIndex(x, y);
    final tileProps = props.skwerTiles[tileIndex]!;
    return SizedBox(
      key: tileProps.key,
      width: tileSize,
      height: tileSize,
      child: MouseRegion(
        onEnter: (event) {
          if (tileProps.state.value.isActive) {
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
            valueListenable: props.puzzle,
            builder: (_, __, ___) => ExcludeFocus(
              excluding:
                  !(props.puzzle.value?.zone.containsTile(tileIndex) ?? true),
              child: Focus(
                focusNode: tileProps.focusNode,
                onFocusChange: (hasFocus) => game.focus(tileIndex, hasFocus),
                onKeyEvent: (_, event) =>
                    _onTileKeyEvent(event, tileProps, tileIndex),
                child: SkwerTile(props: tileProps, gameProps: game.gameProps),
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
      if (game.props.puzzle.value == null) {
        game.reset();
      } else {
        game.resetPuzzle();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      final didClearFocus = game.clearFocus();
      if (!didClearFocus && game.props.puzzle.value != null) {
        game.props.puzzle.value = null;
        game.reset();
        return KeyEventResult.handled;
      }
      return didClearFocus ? KeyEventResult.handled : KeyEventResult.ignored;
    } else if (_kDigits.contains(event.logicalKey)) {
      final digit = _kDigits.indexOf(event.logicalKey) + 1;
      game.startPuzzle(digit);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      game.clearFocus();
      game.reset(skwer: (game.props.skwer + 1) % 3);
      if (game.props.puzzle.value != null) {
        game.resetPuzzle();
      }
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
      if (RawKeyboard.instance.keysPressed.intersection({
            LogicalKeyboardKey.shiftLeft,
            LogicalKeyboardKey.shiftRight,
            LogicalKeyboardKey.space,
            LogicalKeyboardKey.enter,
          }).length >
          1) {
        game.props.puzzle.value = null;
        game.reset(skwer: tileProps.state.value.skwer % 3);
      } else {
        game.rotate(GameRotation(index: tileIndex, delta: 1));
      }
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

    if (tile.state.value.isActive) {
      game.rotate(GameRotation(index: tile.index, delta: 1));
    }
  }

  void _maybeEnter(SkwerTileProps tile) {
    if (tile.isFocused.value) {
      return;
    }

    if (tile.state.value.isActive) {
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
