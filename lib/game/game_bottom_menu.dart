import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/game/game.dart';
import 'package:skwer/game/game_rotation_counter_painter.dart';

class GameBottomMenu extends StatelessWidget {
  final Game game;
  final VoidCallback onHelp;

  late final GameRotationCounterPainter _painter =
      GameRotationCounterPainter(props: game.props);

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
                          if (!game.props.hasPuzzle) {
                            if (game.props.rotationCounter.value > 0) {
                              game.undoLastRotation();
                            } else {
                              game.startPuzzle(game.prefs.puzzleSize.value);
                            }
                          } else {
                            if (game.props.puzzleLength == 0) {
                              game.startPuzzle(game.prefs.puzzleSize.value);
                            } else {
                              game.undoLastRotation();
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
