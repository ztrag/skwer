import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/game/game_rotation_counter_painter.dart';

const kGameBottomCounterHeight = kGameRotationCounterRowTileSize * 1.5;

class GameBottomCounter extends StatelessWidget {
  final GameRotationCounterPainter _painter;

  GameBottomCounter({Key? key, required GameProps props})
      : _painter = GameRotationCounterPainter(
          props: props,
          style: GameRotationCounterPainterStyle.row,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(
            kGameBottomCounterHeight - kGameRotationCounterRowTileSize),
        child: SizedBox(
          height: kGameRotationCounterRowTileSize,
          child: CustomPaint(painter: _painter),
        ),
      ),
    );
  }
}
