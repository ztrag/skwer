import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/mosaic/mosaic_grid.dart';

class SkwerTile extends StatelessWidget {
  final SkwerTileProps props;
  final _SkwerTilePaint _paint;

  SkwerTile({
    required this.props,
  })  : _paint = _SkwerTilePaint(props.state),
        super(key: props.key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _paint);
  }
}

class _SkwerTilePaint extends CustomPainter {
  static final Paint _focusPaint = _buildFocusPaint();

  final MosaicGrid grid = MosaicGrid();
  final ValueNotifier<SkwerTileState> state;

  // FIXME animate on state change

  _SkwerTilePaint(this.state) : super(repaint: state);

  @override
  void paint(Canvas canvas, Size size) {
    if (state.value.isFocused) {
      final x = size.width * 0.02;
      _focusPaint.strokeWidth = size.width * 0.13;
      canvas.drawRect(
        Rect.fromLTRB(x, x, size.width - x, size.height - x),
        _focusPaint,
      );
    }
    grid.paint(canvas, size, skTileColors[state.value.count % 3]);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _SkwerTilePaint) {
      return true;
    }

    // FIXME
    return true;
  }

  static Paint _buildFocusPaint() {
    final paint = Paint();
    paint.color = skFocusColor;
    paint.style = PaintingStyle.stroke;
    return paint;
  }
}

class SkwerTileIndex {
  final int x;
  final int y;

  const SkwerTileIndex(this.x, this.y);

  @override
  int get hashCode => x * 1000 + y;

  @override
  bool operator ==(Object other) {
    if (other is! SkwerTileIndex) {
      return false;
    }
    return other.x == x && other.y == y;
  }

  @override
  String toString() => 'TileIndex[$x,$y]';
}

class SkwerTileProps {
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<SkwerTileState> state = ValueNotifier(SkwerTileState());
  final ValueKey<SkwerTileIndex> key;

  SkwerTileProps({
    required SkwerTileIndex tileIndex,
  }) : key = ValueKey(tileIndex);
}

class SkwerTileState {
  int count = 0;
  bool isFocused = false;

  SkwerTileState();

  SkwerTileState._(this.count, this.isFocused);

  factory SkwerTileState.addCount(SkwerTileState state, int value) {
    return SkwerTileState._(state.count + value, false);
  }

  factory SkwerTileState.onFocus(SkwerTileState state, bool hasFocus) {
    return SkwerTileState._(state.count, hasFocus);
  }
}
