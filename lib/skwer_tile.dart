import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/mosaic/mosaic_animation.dart';
import 'package:skwer/mosaic/mosaic_grid.dart';

class SkwerTile extends StatefulWidget {
  final SkwerTileProps props;

  SkwerTile({
    required this.props,
  }) : super(key: props.key);

  @override
  State<SkwerTile> createState() => _SkwerTileState();
}

class _SkwerTileState extends State<SkwerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final _SkwerTilePaint _paint;
  late SkwerTileState _previousState;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _paint = _SkwerTilePaint(widget.props.state, _animation);
    _previousState = widget.props.state.value;

    widget.props.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.props.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    final currentState = widget.props.state.value;
    if (currentState.count != _previousState.count) {
      _paint.animationStart = _previousState;
      _paint.animationEnd = currentState;
      _animationController.forward(from: 0);
    }
    _previousState = currentState;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: CustomPaint(painter: _paint));
  }
}

class _SkwerTilePaint extends CustomPainter {
  static final Paint _focusPaint = _buildFocusPaint();

  final MosaicGrid grid = MosaicGrid();
  final ValueNotifier<SkwerTileState> state;
  final Animation<double> animation;

  SkwerTileState animationStart = SkwerTileState();
  SkwerTileState animationEnd = SkwerTileState();

  _SkwerTilePaint(this.state, this.animation)
      : super(repaint: Listenable.merge([state, animation]));

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

    grid.paint(
      canvas,
      size,
      MosaicAnimation(
        skTileColors[animationStart.count % 3],
        skTileColors[animationEnd.count % 3],
        animation.value,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _SkwerTilePaint) {
      return true;
    }

    return false;
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
