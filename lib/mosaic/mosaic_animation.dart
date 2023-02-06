import 'dart:math';
import 'dart:ui';

class MosaicAnimation {
  final Color start;
  final Color end;
  final Point<double> dir;
  final double value;

  const MosaicAnimation(
    this.start,
    this.end,
    this.dir,
    this.value,
  );
}
