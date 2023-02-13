import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/game/game.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/game/game_rotation.dart';
import 'package:skwer/game/puzzle.dart';
import 'package:skwer/platform.dart';
import 'package:skwer/tile/skwer_tile.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_props.dart';

final _kDigits = [
  LogicalKeyboardKey.digit1.keyId,
  LogicalKeyboardKey.digit2.keyId,
  LogicalKeyboardKey.digit3.keyId,
  LogicalKeyboardKey.digit4.keyId,
  LogicalKeyboardKey.digit5.keyId,
  LogicalKeyboardKey.digit6.keyId,
  LogicalKeyboardKey.digit7.keyId,
  LogicalKeyboardKey.digit8.keyId,
  LogicalKeyboardKey.digit9.keyId,
  LogicalKeyboardKey.digit0.keyId,
];

class GameWidget extends StatefulWidget {
  const GameWidget({Key? key}) : super(key: key);

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final Game game = Game();

  final Map<Rect, SkwerTileProps> _positions = {};
  Future? _delayedUnfocus;
  SkwerTileIndex? _singlePointer;

  GameProps get props => game.gameProps.value;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () => game.startPuzzle(7));
  }

  @override
  Widget build(BuildContext context) {
    window.onKeyData = _onKeyData;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final mediaQueryData = MediaQuery.of(context);
    final mediaSize = mediaQueryData.size;
    final size = Platform.isMobile
        ? Size(mediaSize.width, mediaSize.height - 150)
        : mediaSize;
    final tileSize = _getTileSize(size);

    final numTilesX = (size.width / tileSize).floor();
    final numTilesY = (size.height / tileSize).floor();
    if (numTilesX != props.numTilesX || numTilesY != props.numTilesY) {
      _positions.clear();
      game.resize(numTilesX, numTilesY);
    }

    return Stack(
      children: [
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
      child: Padding(
        padding: padding,
        child: MouseRegion(
          onEnter: (event) {
            if (tileProps.state.value.isActive) {
              tileProps.focusNode.requestFocus();
              _delayedUnfocus = null;
            }
          },
          onExit: (event) {
            if (tileProps.state.value.hasFocus) {
              _delayedUnfocus =
                  Future.delayed(const Duration(milliseconds: 50), () {
                if (tileProps.state.value.hasFocus && _delayedUnfocus != null) {
                  tileProps.focusNode.unfocus();
                }
              });
            }
          },
          child: ValueListenableBuilder<Puzzle?>(
            valueListenable: props.puzzle,
            builder: (_, __, ___) => ExcludeFocus(
              excluding:
                  !(props.puzzle.value?.zone.containsTile(tileIndex) ?? true),
              child: Focus(
                focusNode: tileProps.focusNode,
                onFocusChange: (hasFocus) => game.focus(tileIndex, hasFocus),
                onKeyEvent: (_, event) {
                  if (event is! KeyDownEvent) {
                    return KeyEventResult.ignored;
                  }

                  if (event.logicalKey == LogicalKeyboardKey.space) {
                    if (RawKeyboard.instance.keysPressed.intersection({
                      LogicalKeyboardKey.shiftLeft,
                      LogicalKeyboardKey.shiftRight
                    }).isNotEmpty) {
                      game.props.puzzle.value = null;
                      game.reset(skwer: tileProps.state.value.skwer % 3);
                    } else {
                      game.rotate(GameRotation(index: tileIndex, delta: 1));
                    }
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: SkwerTile(props: tileProps, gameProps: game.gameProps),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _initPositions() {
    if (_positions.isNotEmpty) {
      return;
    }

    for (final tile in game.props.skwerTiles.values) {
      final box = tile.key.currentContext?.findRenderObject() as RenderBox;
      // final start = box.localToGlobal(Offset.zero);
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
    if (tile.state.value.hasFocus) {
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

  SkwerTileProps? _findTileAtPosition(Offset position) {
    _initPositions();
    for (final tile in _positions.entries) {
      if (tile.key.contains(position)) {
        return tile.value;
      }
    }

    return null;
  }

  bool _onKeyData(KeyData keyData) {
    if (keyData.type == KeyEventType.down) {
      if (keyData.logical == LogicalKeyboardKey.keyR.keyId) {
        game.resetPuzzle();
        return true;
      } else if (keyData.logical == LogicalKeyboardKey.escape.keyId) {
        return game.clearFocus();
      } else if (_kDigits.contains(keyData.logical)) {
        _handleDigit(keyData.logical);
        return true;
      }
    }
    return false;
  }

  void _handleDigit(int key) {
    final digit = _kDigits.indexOf(key) + 1;
    game.startPuzzle(digit);
  }

  double _getTileSize(Size size) {
    return 80;
  }
}
