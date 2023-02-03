import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MosaicTile {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static final Paint _paint = _buildPaint();
  static final Path _path = Path();
  static final Random _random = Random();

  final List<Point<double>> points;
  final double _colorD1;

  MosaicTile(this.points) : _colorD1 = _d1;

  static Paint _buildPaint() {
    return Paint();
  }

  void paint(Canvas canvas, Size size, Color color) {
    _path.reset();
    _path.moveTo(points.first.x * size.width, points.first.y * size.height);
    for (int i = 1; i < points.length; i++) {
      _path.lineTo(points[i].x * size.width, points[i].y * size.height);
    }
    _path.lineTo(points.first.x * size.width, points.first.y * size.height);

    _paint.color = _colorD1 > 1
        ? Color.lerp(color, white, _colorD1 - 1)!
        : Color.lerp(color, black, 1 - _colorD1)!;

    canvas.drawPath(_path, _paint);
  }

  static double get _d1 {
    const d1 = 0.7;
    return (1 - d1 / 2 + d1 * _random.nextDouble());
  }
}
