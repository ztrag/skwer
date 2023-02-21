import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/game/game.dart';

class GameBottomMenu extends StatelessWidget {
  final Game game;
  final VoidCallback onHelp;

  late final _GameMenuMainPainter _painter = _GameMenuMainPainter(game);

  GameBottomMenu({
    Key? key,
    required this.game,
    required this.onHelp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: game.props.skwer,
      builder: (_, skwer, __) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Theme(
            data: ThemeData(
                textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
              foregroundColor: skTileColors[skwer % 3], // Text Color
            ))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => game.prefs.tileLevel++,
                  child: const Icon(Icons.zoom_out_map),
                ),
                TextButton(
                  onPressed: () => game.rotateBase(),
                  child: const Icon(Icons.compare_arrows),
                ),
                ValueListenableBuilder(
                  valueListenable: game.props.puzzle,
                  builder: (_, __, ___) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onLongPress: () {
                          if (game.props.hasPuzzle) {
                            game.endPuzzle();
                          } else {
                            game.reset(skwer: game.props.skwer.value);
                          }
                        },
                        onPressed: () {
                          // if (game.props.puzzleLength == 0) {
                          if (!game.props.hasPuzzle) {
                            if (game.props.rotationCounter.value > 0) {
                              game.undoLastRotation();
                            } else {
                              game.startPuzzle(game.prefs.puzzleSize.value);
                            }
                          } else {
                            if (game.props.puzzleLength == 0) {
                              game.startPuzzle(game.prefs.puzzleSize.value);
                            } else if (game.rotations.length >
                                game.props.puzzleLength) {
                              game.undoLastRotation();
                            } else {
                              game.resetPuzzle();
                            }
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
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final puzzleSize = game.prefs.puzzleSize.value % 8 + 1;
                    game.prefs.puzzleSize.value = puzzleSize;
                    if ((game.props.puzzle.value?.rotations.isEmpty ?? true) ||
                        puzzleSize == 1) {
                      game.startPuzzle(puzzleSize);
                    } else {
                      game.addToPuzzle();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.square_outlined),
                      ValueListenableBuilder(
                        valueListenable: game.prefs.puzzleSize,
                        builder: (_, __, ___) => Text(
                          '${game.prefs.puzzleSize.value}',
                          textScaleFactor: 0.9,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onHelp,
                  child: const Text('?', textScaleFactor: 1.5),
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
              game.props.skwer,
              game.props.numTiles,
              game.props.rotationCounter,
            ],
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(0);
    final numTiles = max(game.props.numTilesX, game.props.numTilesY);
    final tileSize = size.width / numTiles;
    final space = tileSize * 0.1;
    var count = game.props.rotationCounter.value;
    for (var j = 0; j < numTiles; j++) {
      for (var i = 0; i < numTiles; i++) {
        final countDiv = --count ~/ (numTiles * numTiles);
        final countSkwer = count >= 0 ? (countDiv + 1) : 0;
        final color = skTileColors[(game.props.skwer.value + countSkwer) % 3];
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
