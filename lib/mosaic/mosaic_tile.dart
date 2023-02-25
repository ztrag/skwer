import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/mosaic/color_wave.dart';

class MosaicTile {
  static final Paint _paint = Paint();
  static final Path _path = Path();
  static final Random _random = Random();

  final List<Point<double>> points;
  final Point<double> position;
  final double colorD1;

  MosaicTile(this.points)
      : colorD1 = _d1,
        position = _calcPosition(points);

  static Point<double> _calcPosition(List<Point<double>> points) {
    return points.reduce((a, b) => a + b) * (1 / points.length);
  }

  void paint(
    Canvas canvas,
    Size size,
    double brightness,
    double pressAnimation,
    List<ColorWave> waves,
  ) {
    final transition = _getWaveTransition(waves);
    _path.reset();
    final p = getAnimatedPoints(transition.rotation);
    _path.moveTo(p.first.x * size.width, p.first.y * size.height);
    for (var i = 1; i < p.length; i++) {
      _path.lineTo(p[i].x * size.width, p[i].y * size.height);
    }
    _path.lineTo(p.first.x * size.width, p.first.y * size.height);

    final color = Color.lerp(skWhite, transition.color, pressAnimation)!;
    final colorD2 = color.computeLuminance() < 0.1
        ? 0.0
        : ((color.computeLuminance() > 0.5 ? 1 : 0.75) *
            getAnimatedColorD1 *
            brightness);
    _paint.color = colorD2 > 1
        ? Color.lerp(color, skWhite, colorD2 - 1)!
        : Color.lerp(color, skBlack, 1 - colorD2)!;

    canvas.drawPath(_path, _paint);
  }

  _WaveTransition _getWaveTransition(List<ColorWave> waves) {
    Color? color;
    var rotation = 0.0;
    for (var i = 0; i < waves.length - 1; i++) {
      final animation = _getPositionAnimation(waves[i]);
      if (waves[i].rotate) {
        rotation += animation;
      }
      final waveColor =
          Color.lerp(waves[i + 1].color, waves[i].color, animation);
      if (color == null) {
        color = waveColor;
      } else if (animation < 1) {
        color = Color.lerp(waveColor, color, animation);
      }
    }
    return _WaveTransition(
      color ?? waves.first.color,
      rotation - rotation.floor(),
    );
  }

  List<Point<double>> getAnimatedPoints(double animation) {
    final p = <Point<double>>[];
    var length = points.length;
    for (var i = 0; i < length; i++) {
      p.add(points[i] * animation + points[(i + 1) % length] * (1 - animation));
    }
    return p;
  }

  double get getAnimatedColorD1 => colorD1;

  double _getPositionAnimation(ColorWave wave) {
    if (!wave.rotate) {
      return min(1, wave.animation / 0.6);
    }
    final distFromCenter =
        (position - (wave.direction ?? const Point(0.5, 0.5))).magnitude;
    const maxDistFromCenter = 1.4142;
    final relDistFromCenter = distFromCenter / maxDistFromCenter; // [0, 1];
    return min(1, max(0, 2 * wave.animation - relDistFromCenter));
  }

  static double get _d1 {
    const d1 = 0.6;
    return (0.95 - d1 / 2 + d1 * _random.nextDouble());
  }
}

class _WaveTransition {
  final Color color;
  final double rotation;

  _WaveTransition(this.color, this.rotation);
}
