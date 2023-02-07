import 'dart:math';
import 'dart:ui';

class ColorWave {
  final Color start;
  final Color end;
  final Point<double> direction;
  final double animationValue;

  const ColorWave({
    required this.start,
    required this.end,
    required this.direction,
    required this.animationValue,
  });
}
