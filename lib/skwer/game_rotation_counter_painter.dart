import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/skwer/game_props.dart';

const kGameRotationCounterRowTileSize = 10.0;

enum GameRotationCounterPainterStyle {
  square,
  row,
}

class GameRotationCounterPainter extends CustomPainter {
  final GameRotationCounterPainterStyle style;
  final GameProps props;
  final Paint _paint = Paint();

  GameRotationCounterPainter({
    required this.props,
    this.style = GameRotationCounterPainterStyle.square,
  }) : super(
          repaint: Listenable.merge(
            [
              props.skwer,
              props.board,
              props.rotationCounter,
            ],
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(0);
    var count = props.rotationCounter.value;

    final numTiles = max(props.numTilesX, props.numTilesY);
    final numTilesX = isSquare
        ? numTiles
        : min(size.width / kGameRotationCounterRowTileSize, count);
    final numTilesY = isSquare ? numTiles : 1;

    final tileSize = style == GameRotationCounterPainterStyle.square
        ? size.width / numTiles
        : kGameRotationCounterRowTileSize;
    final space = tileSize * 0.1;

    for (var j = 0; j < numTilesY; j++) {
      for (var i = 0; i < numTilesX; i++) {
        final countDiv = --count ~/ (numTilesX * numTilesY);
        final countSkwer = count >= 0 ? (countDiv + (isSquare ? 1 : 0)) : 0;
        final color = skTileColors[(props.skwer.value + countSkwer) % 3];
        final d1 = _d1(random);
        _paint.color = d1 > 1
            ? Color.lerp(color, skWhite, d1 - 1)!
            : Color.lerp(color, skBlack, 1 - d1)!;

        final dx = i + 0.5 - numTilesX / 2;
        final dy = j + 0.5 - numTilesY / 2;
        final dist = 1.0 * pow(dx * dx + dy * dy, 0.45);
        final squareSize = (tileSize - 2 * space) *
            (isSquare ? min(1, numTiles / 4 / dist) : 0.6);
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

  bool get isSquare => style == GameRotationCounterPainterStyle.square;

  bool get isRow => style == GameRotationCounterPainterStyle.row;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  double _d1(Random random) {
    const d1 = 0.6;
    return (0.95 - d1 / 2 + d1 * random.nextDouble());
  }
}
