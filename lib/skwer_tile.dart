import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/mosaic/mosaic_grid.dart';

class SkwerTile extends StatelessWidget {
  final ValueNotifier<int> state;
  final _SkwerTilePaint _paint;

  SkwerTile({
    required ValueKey<TileIndex> key,
    required this.state,
  })  : _paint = _SkwerTilePaint(state),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _paint);
  }
}

class _SkwerTilePaint extends CustomPainter {
  final MosaicGrid grid = MosaicGrid();
  final ValueNotifier<int> state;

  _SkwerTilePaint(this.state) : super(repaint: state);

  // FIXME animate on state change

  @override
  void paint(Canvas canvas, Size size) {
    grid.paint(canvas, size, skColors[state.value % 3]);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _SkwerTilePaint) {
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
  int get hashCode => x * 1000 + y;

  @override
  bool operator ==(Object other) {
    if (other is! TileIndex) {
      return false;
    }
    return other.x == x && other.y == y;
  }
}
