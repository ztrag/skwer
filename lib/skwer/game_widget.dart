import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/platform.dart';
import 'package:skwer/skwer/game.dart';
import 'package:skwer/skwer/game_background.dart';
import 'package:skwer/skwer/game_bottom_counter.dart';
import 'package:skwer/skwer/game_bottom_menu.dart';
import 'package:skwer/skwer/game_overlay_widget.dart';
import 'package:skwer/skwer/game_props.dart';
import 'package:skwer/skwer/game_rotation.dart';
import 'package:skwer/skwer/puzzle.dart';
import 'package:skwer/tile/skwer_tile.dart';
import 'package:skwer/tile/skwer_tile_props.dart';
import 'package:skwer/tile/tile_index.dart';
import 'package:skwer/util/fast_key_focus_scope.dart';

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
  final VoidCallback onExit;

  const GameWidget({Key? key, required this.onExit}) : super(key: key);

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  late final Game game = Game(GameProps(widget.onExit));
  final FocusScopeNode focusScopeNode = FocusScopeNode();

  final Map<Rect, SkwerTileProps> _positions = {};
  Future? _delayedUnfocus;
  TileIndex? _singlePointer;

  @override
  void initState() {
    super.initState();
    game.props.board.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final mediaQueryData = MediaQuery.of(context);
    final mediaSize = mediaQueryData.size;
    final size = Size(
        mediaSize.width,
        mediaSize.height -
            (Platform.isMobile ? 100 : kGameBottomCounterHeight * 3));
    _positions.clear();
    game.props.size.value = Point(size.width, size.height);

    return Scaffold(
      body: FastKeyFocusScope(
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
                  GameBackground(
                    props: game.props,
                    size: size,
                    tileSize: game.props.tileSize.value,
                  ),
                  Listener(
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: (_) => game.clearFocus(),
                    child: ValueListenableBuilder(
                      valueListenable: game.props.board,
                      builder: (_, board, __) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            board.size.y,
                            (y) => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                board.size.x,
                                (x) =>
                                    _buildTile(x, y, game.props.tileSize.value),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (!Platform.isMobile)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: GameBottomCounter(props: game.props),
                    ),
                  ValueListenableBuilder(
                    valueListenable: game.props.isShowingOverlay,
                    builder: (_, isShowingOverlay, __) => AnimatedOpacity(
                      opacity: isShowingOverlay ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: IgnorePointer(
                        ignoring: !isShowingOverlay,
                        child: GestureDetector(
                            onTap: () =>
                                setState(() => isShowingOverlay = false),
                            child: GameOverlayWidget(gameProps: game.props)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (Platform.isMobile)
              GameBottomMenu(
                game: game,
                onHelp: () => setState(() {
                  game.props.isShowingOverlay.value =
                      !game.props.isShowingOverlay.value;
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(int x, int y, double tileSize) {
    final tileIndex = TileIndex(x, y);
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
        onHover: (event) {
          if (tileProps.isActive.value &&
              !tileProps.isFocused.value &&
              tileProps.focusNode.hasFocus) {
            game.focus(tileProps.index, true);
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
    );
  }

  KeyEventResult _onTopKeyEvent(FastKeyEvent event) {
    if (event.type != FastKeyEventType.down) {
      return KeyEventResult.ignored;
    }

    if (game.props.isShowingOverlay.value) {
      if (game.props.onOverlayKeyEvent != null) {
        return game.props.onOverlayKeyEvent!(event);
      }
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
      final didClearFocus = game.clearFocus();
      if (didClearFocus) {
        return KeyEventResult.handled;
      }

      if (game.props.hasPuzzle) {
        game.endPuzzle();
        return KeyEventResult.handled;
      }

      game.props.isShowingOverlay.value = true;
      return KeyEventResult.handled;
    } else if (_kDigits.contains(event.logicalKey)) {
      final digit = _kDigits.indexOf(event.logicalKey) + 1;
      game.startPuzzle(digit);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      game.rotateBase();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.backslash) {
      game.toggleGameZone();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      game.undoLastRotation();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onTileKeyEvent(
      KeyEvent event, SkwerTileProps tileProps, TileIndex tileIndex) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (game.props.isShowingOverlay.value) {
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

    _singlePointer = tile.value.index;
    _maybeEnter(tile.value, tile.key, event.position);
  }

  void _onPointerMove(PointerMoveEvent event) {
    final tile = _findTileAtPosition(event.position);
    if (tile == null) {
      _singlePointer = null;
      game.clearFocus();
      return;
    }

    if (_singlePointer != tile.value.index) {
      _singlePointer = null;
    }
    _maybeEnter(tile.value, tile.key, event.position);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (Platform.isMobile) {
      game.clearFocus();
    }

    final tile = _findTileAtPosition(event.position);
    if (tile == null) {
      return;
    }

    if (tile.value.isActive.value) {
      game.rotate(GameRotation(index: tile.value.index, delta: 1));
    }
  }

  void _maybeEnter(SkwerTileProps tile, Rect rect, Offset position) {
    tile.hoverPosition.value = position - rect.topLeft;
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

  MapEntry<Rect, SkwerTileProps>? _findTileAtPosition(Offset position) {
    _initPositions();
    for (final tile in _positions.entries) {
      if (tile.key.contains(position)) {
        return tile;
      }
    }

    return null;
  }
}
