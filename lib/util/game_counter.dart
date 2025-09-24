import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';

const kGameCounterRowTileSize = 10.0;
const kGameCounterSquareNumTiles = 7;

enum GameCounterPainterStyle {
  square,
  row,
}

class GameCounterPainter extends CustomPainter {
  final GameCounterPainterStyle style;
  final ValueListenable<int> n;
  final ValueListenable<int>? skwer;
  final ValueListenable<Color>? color;
  final Paint _paint = Paint();

  GameCounterPainter({
    required this.n,
    this.skwer,
    this.color,
    this.style = GameCounterPainterStyle.square,
  }) : super(repaint: Listenable.merge([n, if (skwer != null) skwer]));

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(0);

    var count = n.value;
    final numTilesX = isSquare
        ? kGameCounterSquareNumTiles
        : min(size.width / kGameCounterRowTileSize, count);
    final numTilesY = isSquare ? 7 : 1;

    final tileSize = style == GameCounterPainterStyle.square
        ? size.width / kGameCounterSquareNumTiles
        : kGameCounterRowTileSize;
    final space = tileSize * 0.1;

    for (var j = 0; j < numTilesY; j++) {
      for (var i = 0; i < numTilesX; i++) {
        final countDiv = --count ~/ (numTilesX * numTilesY);
        final countSkwer = count >= 0 ? (countDiv + (isSquare ? 1 : 0)) : 0;
        final c = color?.value ??
            skTileColors[((skwer?.value ?? 0) + countSkwer) % 3];
        final d1 = _d1(random);
        _paint.color = d1 > 1
            ? Color.lerp(c, skWhite, d1 - 1)!
            : Color.lerp(c, skBlack, 1 - d1)!;

        final dx = i + 0.5 - numTilesX / 2;
        final dy = j + 0.5 - numTilesY / 2;
        final dist = 1.0 * pow(dx * dx + dy * dy, 0.45);
        final squareSize = (tileSize - 2 * space) *
            (isSquare ? min(1, kGameCounterSquareNumTiles / 4 / dist) : 0.6);
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

  bool get isSquare => style == GameCounterPainterStyle.square;

  bool get isRow => style == GameCounterPainterStyle.row;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  double _d1(Random random) {
    const d1 = 0.6;
    return (0.95 - d1 / 2 + d1 * random.nextDouble());
  }
}
