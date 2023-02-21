import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/game/game_props.dart';

class GameRotationCounterPainter extends CustomPainter {
  final GameProps props;
  final Paint _paint = Paint();

  GameRotationCounterPainter(this.props)
      : super(
          repaint: Listenable.merge(
            [
              props.skwer,
              props.numTiles,
              props.rotationCounter,
            ],
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(0);
    final numTiles = max(props.numTilesX, props.numTilesY);
    final tileSize = size.width / numTiles;
    final space = tileSize * 0.1;
    var count = props.rotationCounter.value;
    for (var j = 0; j < numTiles; j++) {
      for (var i = 0; i < numTiles; i++) {
        final countDiv = --count ~/ (numTiles * numTiles);
        final countSkwer = count >= 0 ? (countDiv + 1) : 0;
        final color = skTileColors[(props.skwer.value + countSkwer) % 3];
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
