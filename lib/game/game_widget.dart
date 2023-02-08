import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/game/game.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/game/game_rotation.dart';
import 'package:skwer/game/puzzle.dart';
import 'package:skwer/tile/skwer_tile.dart';
import 'package:skwer/tile/skwer_tile_index.dart';

const _kDigits = [
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

class GameWidget extends StatelessWidget {
  final Game game = Game();

  GameWidget({Key? key}) : super(key: key);

  GameProps get props => game.gameProps.value;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 500 || size.height < 500;
    final tileSize = min(
      min(size.height, size.width) / (isSmall ? 6 : 8),
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
          onHover: (event) => tileProps.focusNode.requestFocus(),
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
                  } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
                    game.resetPuzzle();
                    return KeyEventResult.handled;
                  } else if (_kDigits.contains(event.logicalKey)) {
                    _handleDigit(event.logicalKey);
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

  void _handleDigit(LogicalKeyboardKey key) {
    final digit = _kDigits.indexOf(key) + 1;
    game.startPuzzle(digit);
  }
}
