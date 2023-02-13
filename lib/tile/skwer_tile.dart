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
import 'package:skwer/platform.dart';
import 'package:skwer/tile/skwer_tile_props.dart';
import 'package:skwer/tile/skwer_tile_state.dart';

final Random _random = Random();

class SkwerTile extends StatefulWidget {
  final SkwerTileProps props;
  final ValueNotifier<GameProps> gameProps;

  SkwerTile({
    required this.props,
    required this.gameProps,
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
  final ValueNotifier<DateTime?> _focusTime = ValueNotifier(null);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _paint = _SkwerTilePaint(
      widget.props,
      widget.gameProps,
      _animation,
      _focusTime,
    );
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
    final reAnimate = _previousState.skwer < currentState.skwer ||
        _animationController.value > 0.9 ||
        !_animationController.isAnimating;
    if (reAnimate) {
      // FIXME when transitioning, keep transition tile but change colors.
      _paint.animationStart = _previousState;
    }
    _paint.animationEnd = currentState;
    if (reAnimate) {
      _animationController.forward(from: 0);
    }
    _previousState = currentState;
    if (currentState.hasFocus) {
      _focusTime.value = DateTime.now();
    }
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

  final ValueNotifier<DateTime?> _focusTime;

  SkwerTileState animationStart = SkwerTileState();
  SkwerTileState animationEnd = SkwerTileState();

  _SkwerTilePaint(this.props, this.gameProps, this.animation, this._focusTime)
      : super(repaint: Listenable.merge([props.state, animation]));

  @override
  void paint(Canvas canvas, Size size) {
    final x = _tileSize;
    canvas.translate(
      size.width * (1 - x) / 2,
      size.height * (1 - x) / 2,
    );
    size = Size(size.width * x, size.height * x);

    if (animationEnd.hasFocus || animationEnd.isHighlighted) {
      final x = size.width * 0.02;
      _focusPaint.strokeWidth =
          size.width * (animationEnd.hasFocus ? 0.16 : 0.13);
      _focusPaint.color = Color.lerp(
          skTileColors[(animationStart.skwer + 1) % 3],
          skBlack,
          animationEnd.hasFocus
              ? 0.0
              : (animationStart.skwer == 1 ? 0.25 : 0.4))!;
      canvas.drawRect(
        Rect.fromLTRB(x, x, size.width - x, size.height - x),
        _focusPaint,
      );
    }

    final isFailed = animationEnd.isFailed(gameProps.value);
    final isPuzzle = gameProps.value.puzzle.value != null;
    const failedAnimationValue = 0.6;

    _currentGroup.paint(
      canvas,
      size,
      _getBrightness() * _tileOpacity,
      ColorWave(
        start: _getStartColor(),
        end: skTileColors[animationEnd.skwer % 3],
        direction: _getWaveDirectionFromTrigger(),
        animationValue: (isFailed &&
                animationEnd.skwer == animationStart.skwer &&
                !animationStart.hasFocus &&
                !animationEnd.hasFocus)
            ? failedAnimationValue
            : animation.value * (isFailed ? failedAnimationValue : 1),
        rotate: (!isPuzzle && !Platform.isMobile) ||
            animationEnd.skwer > animationStart.skwer &&
                (isPuzzle ||
                    (!isPuzzle &&
                        animationEnd.skwer > gameProps.value.skwer)) ||
            _currentGroup == transition ||
            animationEnd.hasFocus ||
            animationStart.hasFocus ||
            isFailed,
      ),
    );
  }

  bool get _shouldShowRainbow {
    if (gameProps.value.puzzle.value != null) {
      return false;
    }

    final focusTime = _focusTime.value;
    if (focusTime == null) {
      return false;
    }
    return DateTime.now().difference(focusTime) <
        const Duration(milliseconds: 400);
  }

  Color _getStartColor() {
    if (_shouldShowRainbow) {
      return _getRainbowColor();
    }

    if (animationEnd.isLastPressed) {
      return skWhite;
    }

    return skTileColors[animationStart.skwer % 3];
  }

  Color _getRainbowColor() {
    return Color.lerp(
      skTileColors[(animationStart.skwer + 1) % 3],
      skTileColors[(animationStart.skwer + 2) % 3],
      0.25 + 0.5 * _random.nextDouble(),
    )!;
  }

  double _getBrightness() {
    if (animationEnd.isHighlighted &&
        (animationEnd.skwer % 3 != gameProps.value.skwer % 3 ||
            animationEnd.skwer < gameProps.value.skwer)) {
      return 1.05;
    }
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

  double get _tileSize {
    if (props.state.value.hasPuzzle && props.state.value.isActive) {
      return 1;
    }
    final x = 0.9 * min(1.0, sqrt(3 / _cartesianDistFromCenter));
    return pow(x, 1.2).toDouble();
  }

  double get _tileOpacity {
    if (props.state.value.hasPuzzle && props.state.value.isActive) {
      return 1;
    }
    final x = min(1.0, 4 / _cartesianDistFromCenter);
    return pow(x, 1.2).toDouble();
  }

  double get _cartesianDistFromCenter => max(
        (props.index.x + 0.5 - gameProps.value.numTilesX / 2).abs(),
        (props.index.y + 0.5 - gameProps.value.numTilesY / 2).abs(),
      );
}
