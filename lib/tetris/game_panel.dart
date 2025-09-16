import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/tetris/game_props.dart';
import 'package:skwer/tetris/game_tetramino.dart';
import 'package:skwer/tetris/tetramino_widget.dart';

class GamePanel extends StatelessWidget {
  final GameProps gameProps;

  const GamePanel({Key? key, required this.gameProps}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            fontSize: 32,
            color: skWhite,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: gameProps.level,
                    builder: (_, level, __) => Text('${level.value}'),
                  ),
                ],
              ),
              ValueListenableBuilder<Tetramino?>(
                  valueListenable: gameProps.nextTetramino,
                  builder: (_, nextTetramino, __) {
                    if (nextTetramino == null) {
                      return const SizedBox.shrink();
                    }
                    return TetraminoWidget(
                      key: ValueKey(nextTetramino),
                      tetramino: nextTetramino,
                    );
                  }),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: gameProps.score,
                    builder: (_, score, __) => Text('$score'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
