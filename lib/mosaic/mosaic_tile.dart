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

  void paint(
    Canvas canvas,
    Size size,
    double brightness,
    MosaicAnimation animation,
  ) {
    final positionAnimation = _getPositionAnimation(animation);
    _path.reset();
    final p = _getAnimatedPoints(positionAnimation);
    _path.moveTo(p.first.x * size.width, p.first.y * size.height);
    for (int i = 1; i < p.length; i++) {
      _path.lineTo(p[i].x * size.width, p[i].y * size.height);
    }
    _path.lineTo(p.first.x * size.width, p.first.y * size.height);

    final color = _getCurrentColor(animation, positionAnimation);
    final colorD2 = _colorD1 * brightness;
    _paint.color = colorD2 > 1
        ? Color.lerp(color, skWhite, colorD2 - 1)!
        : Color.lerp(color, skBlack, 1 - colorD2)!;

    canvas.drawPath(_path, _paint);
  }

  List<Point<double>> _getAnimatedPoints(double animation) {
    final p = <Point<double>>[];
    var length = points.length;
    for (var i = 0; i < length; i++) {
      p.add(points[i] * animation + points[(i + 1) % length] * (1 - animation));
    }
    return p;
  }

  Color _getCurrentColor(MosaicAnimation animation, double positionAnimation) {
    return Color.lerp(animation.start, animation.end, positionAnimation)!;
  }

  double _getPositionAnimation(MosaicAnimation animation) {
    final distFromCenter = (_position - animation.dir).magnitude;
    const maxDistFromCenter = 1.4142;
    final relDistFromCenter = distFromCenter / maxDistFromCenter; // [0, 1];
    return min(1, max(0, 2 * animation.value - relDistFromCenter));
  }

  static double get _d1 {
    const d1 = 0.7;
    return (0.95 - d1 / 2 + d1 * _random.nextDouble());
  }
}
