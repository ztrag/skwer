import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/mosaic/mosaic_animation.dart';

class MosaicTile {
  static final Paint _paint = _buildPaint();
  static final Path _path = Path();
  static final Random _random = Random();

  final List<Point<double>> points;
  final Point<double> _position;
  final double _colorD1;

  MosaicTile(this.points)
      : _colorD1 = _d1,
        _position = _calcPosition(points);

  static Paint _buildPaint() {
    return Paint();
  }

  static Point<double> _calcPosition(List<Point<double>> points) {
    return points.reduce((a, b) => a + b) * (1 / points.length);
  }

  void paint(Canvas canvas, Size size, MosaicAnimation animation) {
    final positionAnimation = _getPositionAnimation(animation.value);
    _path.reset();
    final p = _getAnimatedPoints(positionAnimation);
    _path.moveTo(p.first.x * size.width, p.first.y * size.height);
    for (int i = 1; i < p.length; i++) {
      _path.lineTo(p[i].x * size.width, p[i].y * size.height);
    }
    _path.lineTo(p.first.x * size.width, p.first.y * size.height);

    final color = _getCurrentColor(animation, positionAnimation);
    _paint.color = _colorD1 > 1
        ? Color.lerp(color, skWhite, _colorD1 - 1)!
        : Color.lerp(color, skBlack, 1 - _colorD1)!;

    canvas.drawPath(_path, _paint);
  }

  List<Point> _getAnimatedPoints(double positionAnimation) {
    return <Point>[
      (points[0] * positionAnimation + points[1] * (1 - positionAnimation)),
      (points[1] * positionAnimation + points[2] * (1 - positionAnimation)),
      (points[2] * positionAnimation + points[3] * (1 - positionAnimation)),
      (points[3] * positionAnimation + points[0] * (1 - positionAnimation)),
    ];
  }

  Color _getCurrentColor(MosaicAnimation animation, double positionAnimation) {
    return Color.lerp(animation.start, animation.end, positionAnimation)!;
  }

  double _getPositionAnimation(double animation) {
    final distFromCenter = (_position - const Point(0.5, 0.5)).magnitude;
    const maxDistFromCenter = 0.70710678118; // sqrt(0.5^2 + 0.5^2);
    final relDistFromCenter = distFromCenter / maxDistFromCenter; // [0, 1];
    return min(1, max(0, 2 * animation - relDistFromCenter));
  }

  static double get _d1 {
    const d1 = 0.7;
    return (1 - d1 / 2 + d1 * _random.nextDouble());
  }
}
