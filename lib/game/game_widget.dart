import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/game/game.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/game/game_rotation.dart';
import 'package:skwer/game/puzzle.dart';
import 'package:skwer/tile/skwer_tile.dart';
import 'package:skwer/tile/skwer_tile_index.dart';

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

const Size kMaxSize = Size(1200, 900);

class GameWidget extends StatelessWidget {
  final Game game = Game();
  Future? _delayedUnfocus;

  GameWidget({Key? key}) : super(key: key);

  GameProps get props => game.gameProps.value;

  @override
  Widget build(BuildContext context) {
    window.onKeyData = _onKeyData;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    var mediaSize = MediaQuery.of(context).size;
    final size = Size(
      min(kMaxSize.width, mediaSize.width),
      min(kMaxSize.height, mediaSize.height),
    );
    final isSmall = size.width < 500 || size.height < 500;
    final tileSize = min(
      min(size.height, size.width) / (isSmall ? 6 : 9),
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
                    if (_isMenuAction()) {
                      _onMenuAction(tileIndex);
                    } else {
                      game.rotate(GameRotation(index: tileIndex, delta: 1));
                    }
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: GestureDetector(
                  onTap: () => game.rotate(
                    GameRotation(index: tileIndex, delta: 1),
                  ),
                  onLongPress: () => _onMenuAction(tileIndex),
                  child: SkwerTile(props: tileProps, gameProps: game.gameProps),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isMenuAction() {
    return RawKeyboard.instance.keysPressed.intersection({
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight
    }).isNotEmpty;
  }

  void _onMenuAction(SkwerTileIndex trigger) {
    if (trigger.y == game.props.numTilesY - 1) {
      if (trigger.x == game.props.numTilesX - 1) {
        game.resetPuzzle();
      } else {
        game.startPuzzle(trigger.x + 3);
      }
    } else {
      game.reset(trigger: trigger, reSkwer: true);
    }
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
}
