import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';

class Tile extends StatelessWidget {
  final ValueNotifier<int> state;
  final _TilePaint _paint;

  Tile({
    required ValueKey<TileIndex> key,
    required this.state,
  })  : _paint = _TilePaint(state),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _paint);
  }
}

class _TilePaint extends CustomPainter {
  final ValueNotifier<int> state;

  _TilePaint(this.state) : super(repaint: state);

  // FIXME animate on state change

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);

    final paint = Paint();
    paint.color = skColors[state.value % 3];

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _TilePaint) {
      return true;
    }

    // FIXME
    return true;
  }
}

class TileIndex {
  final int x;
  final int y;

  const TileIndex(this.x, this.y);

  @override
  int get hashCode => x*1000 + y;

  @override
  bool operator ==(Object other) {
    if (other is! TileIndex) {
      return false;
    }
    return other.x == x && other.y == y;
  }
}
