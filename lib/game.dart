import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skwer/tile.dart';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final Map<TileIndex, ValueNotifier<int>> state =
      <TileIndex, ValueNotifier<int>>{};

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tileSize = min(
      min(size.height, size.width) / 8.0,
      max(size.height, size.width) / 9.0,
    );
    final padding = EdgeInsets.all(tileSize * 0.06);

    final numTilesX = (size.width / tileSize).floor();
    final numTilesY = (size.height / tileSize).floor();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        numTilesY,
        (j) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            numTilesX,
            (i) {
              final tileIndex = TileIndex(i, j);
              final tileState = state[tileIndex] ?? ValueNotifier<int>(0);
              state[tileIndex] = tileState;

              return SizedBox(
                width: tileSize,
                height: tileSize,
                child: Padding(
                  padding: padding,
                  child: GestureDetector(
                    onTap: () {
                      // FIXME use skwer rules
                      tileState.value = tileState.value + 1;
                    },
                    child: Tile(
                      key: ValueKey<TileIndex>(tileIndex),
                      state: tileState,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
