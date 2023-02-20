import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/game/game.dart';

class GameMenuButton extends StatelessWidget {
  final Game game;
  final VoidCallback onHelp;

  late final _GameMenuMainPainter _painter = _GameMenuMainPainter(game);

  GameMenuButton({
    Key? key,
    required this.game,
    required this.onHelp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: game.gameProps,
      builder: (_, props, __) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Theme(
            data: ThemeData(
                textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
              foregroundColor:
                  skTileColors[game.gameProps.value.skwer % 3], // Text Color
            ))),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: TextButton(
                    onPressed: () => game.prefs.tileLevel++,
                    child: const Icon(Icons.zoom_out_map),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        game.reset(skwer: (game.props.skwer + 2) % 3);
                        if (game.props.hasPuzzle) {
                          game.resetPuzzle();
                        }
                      },
                      child: const Icon(Icons.chevron_left),
                    ),
                    TextButton(
                      onLongPress: () {
                        if (game.props.hasPuzzle) {
                          game.endPuzzle();
                        } else {
                          game.reset(skwer: game.props.skwer);
                        }
                      },
                      onPressed: () {
                        if (!game.props.hasPuzzle) {
                          game.startPuzzle(1);
                        } else {
                          if (game.rotations.length ==
                              game.props.puzzle.value!.rotations.length) {
                            game.addToPuzzle();
                          }
                          game.resetPuzzle();
                        }
                      },
                      child: RepaintBoundary(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CustomPaint(painter: _painter),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        game.reset(skwer: (game.props.skwer + 1) % 3);
                        if (game.props.hasPuzzle) {
                          game.resetPuzzle();
                        }
                      },
                      child: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  child: TextButton(
                    onPressed: onHelp,
                    child: const Icon(Icons.help_center_outlined),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GameMenuMainPainter extends CustomPainter {
  final Game game;
  final Paint _paint = Paint();

  _GameMenuMainPainter(this.game)
      : super(
          repaint: Listenable.merge(
            [
              game.gameProps,
              game.rotationCounter,
            ],
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(0);
    final numTiles = max(game.props.numTilesX, game.props.numTilesY);
    final tileSize = size.width / numTiles;
    final space = tileSize * 0.1;
    final baseColor = skTileColors[game.gameProps.value.skwer % 3];
    final puzzleColor = skTileColors[(game.gameProps.value.skwer + 1) % 3];
    var count = game.rotationCounter.value;
    for (var j = 0; j < numTiles; j++) {
      for (var i = 0; i < numTiles; i++) {
        final color = --count >= 0 ? puzzleColor : baseColor;
        final d1 = _d1(random);
        _paint.color = d1 > 1
            ? Color.lerp(color, skWhite, d1 - 1)!
            : Color.lerp(color, skBlack, 1 - d1)!;

        final dx = i + 0.5 - numTiles / 2;
        final dy = j + 0.5 - numTiles / 2;
        final dist = 1.0 * pow(dx * dx + dy * dy, 0.45);
        final squareSize = (tileSize - 2 * space) * min(1, numTiles / 4 / dist);
        final left = i * tileSize + (tileSize - squareSize) / 2;
        final top = j * tileSize + (tileSize - squareSize) / 2;
        canvas.drawRect(
          Rect.fromLTRB(
            left,
            top,
            left + squareSize,
            top + squareSize,
          ),
          _paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  double _d1(Random random) {
    const d1 = 0.6;
    return (0.95 - d1 / 2 + d1 * random.nextDouble());
  }
}
