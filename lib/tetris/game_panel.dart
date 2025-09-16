import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }
}
