import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/mosaic/color_wave.dart';
import 'package:skwer/mosaic/grid_mosaic.dart';
import 'package:skwer/mosaic/mosaic.dart';
import 'package:skwer/mosaic/rosetta_mosaic.dart';
import 'package:skwer/mosaic/transition_mosaic.dart';

final Random _random = Random();

class SkwerTile extends StatefulWidget {
  final SkwerTileProps props;

  SkwerTile({
    required this.props,
  }) : super(key: ValueKey(props.index));

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
      duration: const Duration(milliseconds: 350),
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
    _animationController.dispose();
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

  final Mosaic grid = GridMosaic();
  final Mosaic rosetta = MosaicRosetta();
  late final TransitionMosaic transition = TransitionMosaic(grid, rosetta);

  final SkwerTileProps props;
  final Animation<double> animation;

  SkwerTileState animationStart = SkwerTileState();
  SkwerTileState animationEnd = SkwerTileState();

  _SkwerTilePaint(this.props, this.animation)
      : super(repaint: Listenable.merge([props.state, animation]));

  @override
  void paint(Canvas canvas, Size size) {
    if (animationEnd.hasFocus) {
      final x = size.width * 0.02;
      _focusPaint.strokeWidth = size.width * 0.13;
      _focusPaint.color = skTileColors[(animationStart.skwer + 1) % 3];
      canvas.drawRect(
        Rect.fromLTRB(x, x, size.width - x, size.height - x),
        _focusPaint,
      );
    }

    _currentGroup.paint(
      canvas,
      size,
      props.state.value.skwer > 10 // FIXME game skwer
          ? (props.isActive ? 0.7 : 0.3)
          : (props.isActive ? 1 : 0.9),
      ColorWave(
        start: animationStart.skwer == animationEnd.skwer
            ? (animationEnd.isLastPressed
                ? skWhite
                : Color.lerp(
                    skTileColors[(animationStart.skwer + 1) % 3],
                    skTileColors[(animationStart.skwer + 2) % 3],
                    0.25 + 0.5 * _random.nextDouble(),
                  )!)
            : skTileColors[animationStart.skwer % 3],
        end: skTileColors[animationEnd.skwer % 3],
        direction: _getWaveDirectionFromTrigger(),
        animationValue: animation.value,
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

  Mosaic get _currentGroup {
    if (animationStart.skwer >= -2 && animationEnd.skwer <= -3) {
      transition.dir = 1;
      return transition;
    } else if (animationStart.skwer <= -3 && animationEnd.skwer >= -2) {
      transition.dir = -1;
      return transition;
    }
    return props.state.value.skwer < -2 ? rosetta : grid;
  }

  static Paint _buildFocusPaint() {
    final paint = Paint();
    paint.style = PaintingStyle.stroke;
    return paint;
  }

  Point<double> _getWaveDirectionFromTrigger() {
    if (props.state.value.trigger == null) {
      return const Point(0.5, 0.5);
    }
    final trigger = props.state.value.trigger!;
    final target = props.index;
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

  SkwerTileIndex translate(int x, int y) =>
      SkwerTileIndex(this.x + x, this.y + y);
}

class SkwerTileProps {
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<SkwerTileState> state = ValueNotifier(SkwerTileState());
  final SkwerTileIndex index;

  SkwerTileProps({required this.index});

  bool get isActive {
    return true;
    // FIXME based on game
    // final index = key.value;
    // return index.x > 3 && index.x <= 8 && index.y > 1 && index.y <= 5;
  }
}

class SkwerTileState {
  int skwer = 0;
  bool hasFocus = false;
  bool isLastPressed = false;
  SkwerTileIndex? trigger;

  SkwerTileState();

  SkwerTileState._({
    required this.skwer,
    this.hasFocus = false,
    this.isLastPressed = false,
    this.trigger,
  });

  factory SkwerTileState.reset(
    SkwerTileState state,
    SkwerTileIndex trigger,
    int skwer,
  ) {
    return SkwerTileState._(
      skwer: skwer,
      trigger: trigger,
      hasFocus: state.hasFocus,
    );
  }

  factory SkwerTileState.rotate(
    SkwerTileState state,
    SkwerTileIndex trigger,
    int skwerDelta,
  ) {
    return SkwerTileState._(
      skwer: state.skwer + skwerDelta,
      trigger: trigger,
    );
  }

  factory SkwerTileState.onFocus(
    SkwerTileState state,
    bool hasFocus,
  ) {
    return SkwerTileState._(
      skwer: state.skwer,
      hasFocus: hasFocus,
      trigger: state.trigger,
    );
  }

  factory SkwerTileState.onPress(SkwerTileState state) {
    return SkwerTileState._(
      skwer: state.skwer,
      isLastPressed: true,
      hasFocus: true,
    );
  }
}
