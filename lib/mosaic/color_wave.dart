import 'dart:math';
import 'dart:ui';

const Duration kColorWaveAnimationDuration = Duration(milliseconds: 400);

class ColorWave {
  final Color color;
  final double animation;
  final bool rotate;
  final Point<double> direction;

  const ColorWave({
    required this.color,
    required this.animation,
    required this.rotate,
    required this.direction,
  });
}
