import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skwer/tetris/game.dart';
import 'package:skwer/tetris/level.dart';
import 'package:skwer/util/game_counter.dart';

class GameBottomMenu extends StatelessWidget {
  final Game game;
  final VoidCallback onHelp;

  late final GameCounterPainter _painter = GameCounterPainter(
    n: game.props.score,
    color: LevelToColorListener(game.props.level),
  );

  GameBottomMenu({
    Key? key,
    required this.game,
    required this.onHelp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ListenableBuilder(
        listenable: _painter.color!,
        builder: (_, child) => Theme(
            data: ThemeData(
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: _painter.color!.value,
                ),
              ),
            ),
            child: child!),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                game.props.prefs.tileSizeLevel++;
              },
              child: const Icon(Icons.zoom_out_map),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
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
            TextButton(
              onPressed: onHelp,
              child: const Text(
                '?',
                textScaler: TextScaler.linear(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelToColorListener extends ValueNotifier<Color> {
  final ValueListenable<Level> level;

  LevelToColorListener(this.level) : super(level.value.borderColor) {
    level.addListener(_onLevel);
  }

  void _onLevel() {
    value = level.value.borderColor;
  }
}
