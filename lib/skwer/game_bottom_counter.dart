import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/skwer/game_props.dart';
import 'package:skwer/util/game_counter.dart';

const kGameBottomCounterHeight = kGameCounterRowTileSize * 1.5;

class GameBottomCounter extends StatelessWidget {
  final GameCounterPainter _painter;

  GameBottomCounter({Key? key, required GameProps props})
      : _painter = GameCounterPainter(
          n: props.rotationCounter,
          skwer: props.skwer,
          style: GameCounterPainterStyle.row,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(
            kGameBottomCounterHeight - kGameCounterRowTileSize),
        child: SizedBox(
          height: kGameCounterRowTileSize,
          child: CustomPaint(painter: _painter),
        ),
      ),
    );
  }
}
