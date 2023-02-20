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
  final GameProps gameProps;

  SkwerTile({
    required this.props,
    required this.gameProps,
  }) : super(key: ValueKey(props.index));

  @override
  State<SkwerTile> createState() => _SkwerTileState();
}

class _SkwerTileState extends State<SkwerTile> with TickerProviderStateMixin {
  final ValueNotifier<Offset?> hoverPosition = ValueNotifier(null);

  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final AnimationController _pressAnimationController;
  late final Animation<double> _pressAnimation;
  late final AnimationController _highlightAnimationController;
  late final Animation<double> _highlightAnimation;
  late final AnimationController _focusAnimationController;
  late final Animation<double> _focusAnimation;
  late final AnimationController _solvedAnimationController;
  late final Animation<double> _solvedAnimation;
  late final AnimationController _activeAnimationController;
  late final Animation<double> _activeAnimation;
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
    _pressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pressAnimation =
        CurveTween(curve: Curves.easeIn).animate(_pressAnimationController);
    _highlightAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _highlightAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_highlightAnimationController);
    _focusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _focusAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_focusAnimationController);
    _solvedAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _solvedAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_solvedAnimationController);
    _activeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _activeAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_activeAnimationController);
    _paint = _SkwerTilePaint(
      widget.props,
      widget.gameProps,
      hoverPosition,
      _animation,
      _pressAnimation,
      _highlightAnimation,
      _focusAnimation,
      _solvedAnimation,
      _activeAnimation,
    );
    _previousState = widget.props.state.value;

    _onStateChanged();
    _setImmediateState();
    _paint.animationStart = _paint.animationEnd;
    widget.props.state.addListener(_onStateChanged);
    widget.props.pressCounter.addListener(_onPressed);
    widget.props.isHighlighted.addListener(_onHighlighted);
    widget.props.isFocused.addListener(_onFocused);
    widget.props.isActive.addListener(_onActive);
    widget.gameProps.isSolved.addListener(_onSolved);
  }

  @override
  void dispose() {
    widget.props.state.removeListener(_onStateChanged);
    widget.props.pressCounter.removeListener(_onPressed);
    widget.props.isHighlighted.removeListener(_onHighlighted);
    widget.props.isFocused.removeListener(_onFocused);
    widget.props.isActive.removeListener(_onActive);
    widget.gameProps.isSolved.removeListener(_onSolved);
    _animationController.dispose();
    _focusAnimationController.dispose();
    _highlightAnimationController.dispose();
    _pressAnimationController.dispose();
    _activeAnimationController.dispose();
    _solvedAnimationController.dispose();
    super.dispose();
  }

  void _setImmediateState() {
    _pressAnimationController.value = 1;
    _highlightAnimationController.value = 0;
    _solvedAnimationController.value = widget.gameProps.isSolved.value ? 1 : 0;
    _activeAnimationController.value = widget.props.isActive.value ? 1 : 0;
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
    if (currentState.immediate) {
      _animationController.value = 1;
      _setImmediateState();
    } else if (reAnimate) {
      _animationController.forward(from: 0);
    }
    _previousState = currentState;
    _onHighlighted();
  }

  void _onPressed() {
    _pressAnimationController.forward(from: 0);
  }

  void _onHighlighted() {
    final skwer = widget.props.state.value.skwer;
    final gameSkwer = widget.gameProps.skwer.value;
    final fullHighlight = skwer % 3 != gameSkwer % 3 || skwer < gameSkwer;
    if (widget.props.isHighlighted.value) {
      if (fullHighlight) {
        _highlightAnimationController.forward();
      } else {
        _highlightAnimationController.value = 0.1;
      }
    } else {
      _highlightAnimationController.reverse();
    }
  }

  void _onFocused() {
    if (widget.props.isFocused.value) {
      _focusAnimationController.forward(from: 0);
    } else {
      if (!widget.gameProps.hasPuzzle) {
        _previousState = widget.props.state.value;
        _paint.animationStart = _previousState;
        _paint.animationEnd = _previousState;
        _animationController.forward(from: 0);
      }
      _focusAnimationController.reverse(from: 1);
    }
  }

  void _onActive() {
    if (widget.props.isActive.value) {
      _activeAnimationController.forward();
    } else {
      _activeAnimationController.reverse();
    }
  }

  void _onSolved() {
    if (widget.gameProps.isSolved.value) {
      _solvedAnimationController.forward();
    } else {
      _solvedAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (hover) => hoverPosition.value = hover.localPosition,
      onEnter: (enter) => hoverPosition.value = enter.localPosition,
      onExit: (exit) => hoverPosition.value = null,
      child: RepaintBoundary(child: CustomPaint(painter: _paint)),
    );
  }
}

class _SkwerTilePaint extends CustomPainter {
  static final Paint _focusPaint = _buildFocusPaint();

  final Mosaic grid = GridMosaic();
  final Mosaic rosetta = MosaicRosetta();
  late final TransitionMosaic transition = TransitionMosaic(grid, rosetta);

  final SkwerTileProps props;
  final GameProps gameProps;
  final ValueNotifier<Offset?> hoverPosition;

  final Animation<double> animation;
  final Animation<double> pressAnimation;
  final Animation<double> highlightAnimation;
  final Animation<double> focusAnimation;
  final Animation<double> solvedAnimation;
  final Animation<double> activeAnimation;

  SkwerTileState animationStart = SkwerTileState();
  SkwerTileState animationEnd = SkwerTileState();

  _SkwerTilePaint(
    this.props,
    this.gameProps,
    this.hoverPosition,
    this.animation,
    this.pressAnimation,
    this.highlightAnimation,
    this.focusAnimation,
    this.solvedAnimation,
    this.activeAnimation,
  ) : super(
          repaint: Listenable.merge([
            gameProps.skwer,
            gameProps.puzzle,
            gameProps.numTiles,
            props.state,
            hoverPosition,
            animation,
            pressAnimation,
            highlightAnimation,
            focusAnimation,
            solvedAnimation,
            activeAnimation,
          ]),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final x = _tileSize;
    canvas.translate(
      size.width * (1 - x) / 2,
      size.height * (1 - x) / 2,
    );
    size = Size(size.width * x, size.height * x);

    if (props.isFocused.value ||
        (highlightAnimation.value > 0 && props.isHighlighted.value)) {
      final x = size.width * 0.02;
      _focusPaint.strokeWidth =
          size.width * (props.isFocused.value ? 0.16 : 0.13);
      _focusPaint.color = Color.lerp(
          skTileColors[(props.state.value.skwer + 1) % 3],
          skBlack,
          props.isFocused.value
              ? 0.0
              : (props.state.value.skwer == 1 ? 0.25 : 0.4))!;
      canvas.drawRect(
        Rect.fromLTRB(x, x, size.width - x, size.height - x),
        _focusPaint,
      );
    }

    final isFailed = animationEnd.isFailed(props, gameProps);
    final isPuzzle = gameProps.hasPuzzle;
    const failedAnimationValue = 0.6;

    _currentGroup.paint(
      canvas,
      size,
      _getBrightness() * _tileOpacity,
      pressAnimation.value,
      ColorWave(
        start: _startColor,
        end: _endColor,
        direction: _getWaveDirectionFromTrigger(),
        animationValue: (props.state.value.trigger == null ? 0.7 : 1) *
            animation.value *
            (isFailed ? failedAnimationValue : 1),
        rotate: (!isPuzzle && !Platform.isMobile) ||
            animationEnd.skwer > animationStart.skwer &&
                (isPuzzle ||
                    (!isPuzzle &&
                        animationEnd.skwer > gameProps.skwer.value)) ||
            _currentGroup == transition ||
            isFailed,
      ),
      props.isActive.value ? hoverPosition.value : null,
    );
  }

  bool get _shouldShowRainbow => !gameProps.hasPuzzle;

  Color get _startColor => _shouldShowRainbow
      ? _getRainbowColor()
      : skTileColors[animationStart.skwer % 3];

  Color get _endColor => skTileColors[animationEnd.skwer % 3];

  Color _getRainbowColor() {
    return Color.lerp(
      skTileColors[(animationStart.skwer + 1) % 3],
      skTileColors[(animationStart.skwer + 2) % 3],
      0.25 + 0.5 * _random.nextDouble(),
    )!;
  }

  double _getBrightness() {
    final start = animationStart.immediate
        ? animationEnd.getBrightness(props, gameProps)
        : animationStart.getBrightness(props, gameProps);
    final end = animationEnd.getBrightness(props, gameProps);
    final x = start * (1 - animation.value) + end * animation.value;
    final solved = solvedAnimation.value;
    final active = activeAnimation.value;
    final z = solved * active * 0.9 +
        solved * (1 - active) * 0.5 +
        (1 - solved) * active * 0.7 +
        (1 - solved) * (1 - active) * 0.15;
    final y = x * z * (1 - highlightAnimation.value) +
        1.05 * highlightAnimation.value;
    return y * (1 - focusAnimation.value) + 1.4 * focusAnimation.value;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _SkwerTilePaint) {
      return true;
    }

    return false;
  }

  Mosaic get _currentGroup {
    final startDelta = animationStart.skwer - gameProps.skwer.value;
    final endDelta = animationEnd.skwer - gameProps.skwer.value;
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
    if (Platform.isMobile) {
      final numTiles = min(
        gameProps.numTilesX,
        gameProps.numTilesY,
      );
      final x = _tileSizeFromNumTiles(numTiles);
      if (gameProps.hasPuzzle && props.isActive.value) {
        return x;
      }
      final z = min(1.0, pow(1 / _cartesianDistFromCenter, 0.7));
      return x * pow(z, 0.5).toDouble();
    }
    final amp = gameProps.hasPuzzle && props.isActive.value ? 0.9 : 0.85;
    final x = amp * min(1.0, pow(2.7 / _cartesianDistFromCenter, 0.7));
    return pow(x, 1.1).toDouble();
  }

  double _tileSizeFromNumTiles(int numTiles) {
    switch (numTiles) {
      case 3:
        return 0.8;
      case 4:
        return 0.85;
      case 5:
        return 0.9;
      case 6:
        return 0.95;
    }
    return 1;
  }

  double get _tileOpacity {
    if (Platform.isMobile) {
      if (gameProps.hasPuzzle) {
        return 1;
      }
      final x = min(1.0, 2 / _cartesianDistFromCenter);
      return pow(x, 1).toDouble();
    }

    if (gameProps.hasPuzzle && props.isActive.value) {
      return 1;
    }
    final x = min(1.0, 5 / _cartesianDistFromCenter);
    return pow(x, 1).toDouble();
  }

  double get _cartesianDistFromCenter {
    final dx = props.index.x + 0.5 - gameProps.numTilesX / 2;
    final dy = props.index.y + 0.5 - gameProps.numTilesY / 2;
    return 1.0 * pow(dx * dx + dy * dy, 0.45);
  }
}
