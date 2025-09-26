import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/tetris/game_props.dart';

class GameBoardSizeHint extends StatelessWidget {
  final GameProps props;
  final Animation<double> animation;

  const GameBoardSizeHint(
      {Key? key, required this.props, required this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _GameBoardSizeHintPainter(this),
      ),
    );
  }
}

class _GameBoardSizeHintPainter extends CustomPainter {
  static final Paint _paint = createPaint();

  final GameBoardSizeHint widget;

  _GameBoardSizeHintPainter(this.widget) : super(repaint: widget.animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (widget.animation.value > 0.99) {
      return;
    }

    _paint.style = PaintingStyle.fill;
    for (var i = 0; i < numTilesX; i++) {
      for (var j = 0; j < numTilesY; j++) {
        _paint.color = Color.lerp(getColorD1(skPurple, i * 10000 + j), skBlack,
            widget.animation.value)!;
        final rectSize = Size(
          size.width / numTilesX,
          size.height / numTilesY,
        );
        canvas.drawRect(getDrawRect(rectSize, i, j), _paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  Color getColorD1(Color color, int seed) {
    const x = 0.6;
    final d1 = 0.95 - x / 2 + x * Random(seed).nextDouble();

    return d1 > 1
        ? Color.lerp(color, skWhite, d1 - 1)!
        : Color.lerp(color, skBlack, 1 - d1)!;
  }

  double getTileSize(int i, int j) {
    final numTiles = 0.8 * min(numTilesX, numTilesY);
    final xDist = 0.2 * numTiles / getCartesianDistFromCenter(i, j);
    final x = 0.75 * min(1.0, pow(xDist, 3));
    return pow(x, 1.1).toDouble();
  }

  double getCartesianDistFromCenter(int i, int j) {
    final dx = i + 0.5 - numTilesX / 2;
    final dy = j + 0.5 - numTilesY / 2;
    return 1.0 * pow(dx.abs() + dy.abs(), 0.4);
  }

  Rect getDrawRect(Size size, int i, int j) {
    final s = size * getTileSize(i, j);
    final x = (i + 0.5) * size.width;
    final y = (j + 0.5) * size.height;
    final sw = max(1, min(10, s.width / 2));
    final sh = max(1, min(10, s.height / 2));
    return Rect.fromLTRB(
      x - sw,
      y - sh,
      x + sw,
      y + sh,
    );
  }

  static Paint createPaint() {
    return Paint();
  }

  int get numTilesX => widget.props.numTilesX;

  int get numTilesY => widget.props.numTilesY;
}
