import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/mosaic/mosaic_animation.dart';
import 'package:skwer/mosaic/mosaic_grid.dart';
import 'package:skwer/mosaic/mosaic_group.dart';
import 'package:skwer/mosaic/mosaic_rosetta.dart';
import 'package:skwer/mosaic/mosaic_transition_group.dart';

final Random _random = Random();

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
    _paint = _SkwerTilePaint(widget.props, _animation);
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
    _paint.animationStart = _previousState;
    _paint.animationEnd = currentState;
    _animationController.forward(from: 0);
    _previousState = currentState;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: CustomPaint(painter: _paint));
  }
}

class _SkwerTilePaint extends CustomPainter {
  static final Paint _focusPaint = _buildFocusPaint();

  final MosaicGroup grid = MosaicGrid();
  final MosaicGroup rosetta = MosaicRosetta();
  final SkwerTileProps props;
  final Animation<double> animation;

  late final MosaicGroupTransition transition =
      MosaicGroupTransition(grid, rosetta);

  SkwerTileState animationStart = SkwerTileState();
  SkwerTileState animationEnd = SkwerTileState();

  _SkwerTilePaint(this.props, this.animation)
      : super(repaint: Listenable.merge([props.state, animation]));

  @override
  void paint(Canvas canvas, Size size) {
    if (animationEnd.hasFocus) {
      final x = size.width * 0.02;
      _focusPaint.strokeWidth = size.width * 0.13;
      _focusPaint.color = skTileColors[(animationStart.count + 1) % 3];
      canvas.drawRect(
        Rect.fromLTRB(x, x, size.width - x, size.height - x),
        _focusPaint,
      );
    }

    _currentGroup.paint(
      canvas,
      size,
      props.state.value.count > 10 // FIXME game count
          ? (props.isActive ? 0.7 : 0.3)
          : (props.isActive ? 1 : 0.9),
      MosaicAnimation(
        animationStart.count == animationEnd.count
            ? (animationEnd.isLastPressed
                ? skWhite
                : Color.lerp(
                    skTileColors[(animationStart.count + 1) % 3],
                    skTileColors[(animationStart.count + 2) % 3],
                    0.25 + 0.5 * _random.nextDouble(),
                  )!)
            : skTileColors[animationStart.count % 3],
        skTileColors[animationEnd.count % 3],
        _getDirFromTrigger(),
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

  MosaicGroup get _currentGroup {
    if (animationStart.count >= -2 && animationEnd.count <= -3) {
      transition.dir = 1;
      return transition;
    } else if (animationStart.count <= -3 && animationEnd.count >= -2) {
      transition.dir = -1;
      return transition;
    }
    return props.state.value.count < -2 ? rosetta : grid;
  }

  static Paint _buildFocusPaint() {
    final paint = Paint();
    paint.style = PaintingStyle.stroke;
    return paint;
  }

  Point<double> _getDirFromTrigger() {
    if (props.state.value.trigger == null) {
      return const Point(0.5, 0.5);
    }
    final trigger = props.state.value.trigger!;
    final target = props.key.value;
    return Point(
      target.x > trigger.x
          ? 0
          : target.x < trigger.x
              ? 1
              : 0.5,
      target.y > trigger.y
          ? 0
          : target.y < trigger.y
              ? 1
              : 0.5,
    );
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

  SkwerTileIndex translate(int x, int y) =>
      SkwerTileIndex(this.x + x, this.y + y);
}

class SkwerTileProps {
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<SkwerTileState> state = ValueNotifier(SkwerTileState());
  final ValueKey<SkwerTileIndex> key;

  SkwerTileProps({
    required SkwerTileIndex tileIndex,
  }) : key = ValueKey(tileIndex);

  bool get isActive {
    return true;
    // FIXME based on game
    // final index = key.value;
    // return index.x > 3 && index.x <= 8 && index.y > 1 && index.y <= 5;
  }
}

class SkwerTileState {
  SkwerTileIndex? trigger;
  int count = 0;
  bool hasFocus = false;
  bool isLastPressed = false;

  SkwerTileState();

  SkwerTileState._({
    required this.count,
    this.hasFocus = false,
    this.isLastPressed = false,
    this.trigger,
  });

  factory SkwerTileState.reset(
    SkwerTileState state,
    SkwerTileIndex trigger,
    int count,
  ) {
    return SkwerTileState._(
      count: count,
      trigger: trigger,
      hasFocus: state.hasFocus,
    );
  }

  factory SkwerTileState.rotate(
    SkwerTileState state,
    SkwerTileIndex trigger,
    int delta,
  ) {
    return SkwerTileState._(
      count: state.count + delta,
      trigger: trigger,
    );
  }

  factory SkwerTileState.onFocus(
    SkwerTileState state,
    bool hasFocus,
  ) {
    return SkwerTileState._(
      count: state.count,
      hasFocus: hasFocus,
      trigger: state.trigger,
    );
  }

  factory SkwerTileState.onPress(SkwerTileState state) {
    return SkwerTileState._(
      count: state.count,
      isLastPressed: true,
      hasFocus: true,
    );
  }
}
