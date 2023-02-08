import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/mosaic/color_wave.dart';
import 'package:skwer/mosaic/grid_mosaic.dart';
import 'package:skwer/mosaic/mosaic.dart';
import 'package:skwer/mosaic/rosetta_mosaic.dart';
import 'package:skwer/mosaic/transition_mosaic.dart';
import 'package:skwer/tile/skwer_tile_props.dart';
import 'package:skwer/tile/skwer_tile_state.dart';

final Random _random = Random();

class SkwerTile extends StatefulWidget {
  final SkwerTileProps props;
  final ValueNotifier<GameProps> gameProps;

  SkwerTile({
    required this.props,
    required this.gameProps,
  }) : super(key: ValueKey(props));

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
    _paint = _SkwerTilePaint(widget.props, widget.gameProps, _animation);
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
    if (_animationController.value == 1) {
      _paint.animationStart = _previousState;
    }
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
  final ValueNotifier<GameProps> gameProps;

  final Animation<double> animation;

  SkwerTileState animationStart = SkwerTileState();
  SkwerTileState animationEnd = SkwerTileState();

  _SkwerTilePaint(this.props, this.gameProps, this.animation)
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
      _getBrightness(),
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

  double _getBrightness() {
    final start = animationStart.getBrightness(gameProps.value);
    final end = animationEnd.getBrightness(gameProps.value);
    return start * (1 - animation.value) + end * animation.value;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _SkwerTilePaint) {
      return true;
    }

    return false;
  }

  Mosaic get _currentGroup {
    final startDelta = animationStart.skwer - gameProps.value.skwer;
    final endDelta = animationEnd.skwer - gameProps.value.skwer;
    if (startDelta >= -2 && endDelta <= -3) {
      transition.dir = 1;
      return transition;
    } else if (startDelta <= -3 && endDelta >= -2) {
      transition.dir = -1;
      return transition;
    }
    return endDelta < -2 ? rosetta : grid;
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
