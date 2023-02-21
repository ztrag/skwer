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
  late final AnimationController _puzzleHighlightAnimationController;
  late final Animation<double> _puzzleHighlightAnimation;
  late final _SkwerTilePaint _paint;
  late SkwerTileState _previousState;

  @override
  void initState() {
    super.initState();

    const puzzleStateDuration = Duration(milliseconds: 300);
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _pressAnimationController =
        AnimationController(duration: puzzleStateDuration, vsync: this);
    _pressAnimation =
        CurveTween(curve: Curves.easeIn).animate(_pressAnimationController);
    _highlightAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _highlightAnimation =
        CurveTween(curve: Curves.ease).animate(_highlightAnimationController);
    _focusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _focusAnimation =
        CurveTween(curve: Curves.ease).animate(_focusAnimationController);
    _solvedAnimationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      reverseDuration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _solvedAnimation =
        CurveTween(curve: Curves.ease).animate(_solvedAnimationController);
    _activeAnimationController =
        AnimationController(duration: puzzleStateDuration, vsync: this);
    _activeAnimation =
        CurveTween(curve: Curves.ease).animate(_activeAnimationController);
    _puzzleHighlightAnimationController =
        AnimationController(duration: puzzleStateDuration, vsync: this);
    _puzzleHighlightAnimation = CurveTween(curve: Curves.ease)
        .animate(_puzzleHighlightAnimationController);
    _paint = _SkwerTilePaint(
      widget.props,
      widget.gameProps,
      _animation,
      _pressAnimation,
      _highlightAnimation,
      _focusAnimation,
      _solvedAnimation,
      _activeAnimation,
      _puzzleHighlightAnimation,
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
    widget.gameProps.skwer.addListener(_onPuzzleHighlightChanged);
  }

  @override
  void dispose() {
    widget.props.state.removeListener(_onStateChanged);
    widget.props.pressCounter.removeListener(_onPressed);
    widget.props.isHighlighted.removeListener(_onHighlighted);
    widget.props.isFocused.removeListener(_onFocused);
    widget.props.isActive.removeListener(_onActive);
    widget.gameProps.isSolved.removeListener(_onSolved);
    widget.gameProps.skwer.removeListener(_onPuzzleHighlightChanged);
    _animationController.dispose();
    _focusAnimationController.dispose();
    _highlightAnimationController.dispose();
    _pressAnimationController.dispose();
    _activeAnimationController.dispose();
    _solvedAnimationController.dispose();
    _puzzleHighlightAnimationController.dispose();
    super.dispose();
  }

  void _setImmediateState() {
    _pressAnimationController.value = 1;
    _highlightAnimationController.value = 0;
    _solvedAnimationController.value = widget.gameProps.isSolved.value ? 1 : 0;
    _activeAnimationController.value = widget.props.isActive.value ? 1 : 0;
    _puzzleHighlightAnimationController.value = 0;
  }

  void _onStateChanged() {
    _onPuzzleHighlightChanged();
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
    if (widget.props.isHighlighted.value) {
      _highlightAnimationController.forward();
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
      _focusAnimationController.value = 0;
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

  void _onPuzzleHighlightChanged() {
    final skwerDelta =
        widget.props.state.value.skwer - widget.gameProps.skwer.value;
    final hasPuzzleHighlight = skwerDelta < 0 || skwerDelta % 3 != 0;
    if (hasPuzzleHighlight) {
      _puzzleHighlightAnimationController.forward();
    } else {
      _puzzleHighlightAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (hover) =>
          widget.props.hoverPosition.value = hover.localPosition,
      onEnter: (enter) =>
          widget.props.hoverPosition.value = enter.localPosition,
      onExit: (exit) => widget.props.hoverPosition.value = null,
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

  final Animation<double> animation;
  final Animation<double> pressAnimation;
  final Animation<double> highlightAnimation;
  final Animation<double> focusAnimation;
  final Animation<double> solvedAnimation;
  final Animation<double> activeAnimation;
  final Animation<double> puzzleHighlightAnimation;

  SkwerTileState animationStart = SkwerTileState();
  SkwerTileState animationEnd = SkwerTileState();

  _SkwerTilePaint(
    this.props,
    this.gameProps,
    this.animation,
    this.pressAnimation,
    this.highlightAnimation,
    this.focusAnimation,
    this.solvedAnimation,
    this.activeAnimation,
    this.puzzleHighlightAnimation,
  ) : super(
          repaint: Listenable.merge([
            gameProps.skwer,
            gameProps.puzzle,
            gameProps.numTiles,
            props.state,
            props.hoverPosition,
            animation,
            pressAnimation,
            highlightAnimation,
            focusAnimation,
            solvedAnimation,
            activeAnimation,
            puzzleHighlightAnimation,
          ]),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final x = 0.88 * _geometricTileSize * _focusTileSize * _pressTileSize;
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
      props.isFocused.value && props.isActive.value
          ? props.hoverPosition.value
          : null,
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
    final solved = solvedAnimation.value;
    final active = activeAnimation.value;
    final puzzle = puzzleHighlightAnimation.value;
    final highlight = highlightAnimation.value;
    final focus = focusAnimation.value;

    final z = (solved * active) * 1 +
        (solved * (1 - active)) * 0.7 +
        ((1 - solved) * active * puzzle) * 1 +
        ((1 - solved) * active * (1 - puzzle)) * 0.7 +
        ((1 - solved) * (1 - active) * puzzle) * 0.75 +
        ((1 - solved) * (1 - active) * (1 - puzzle)) * 0.2;
    final y = z * (1 - highlight * puzzle) + 1.05 * highlight * puzzle;
    return y * (1 - focus) + 1.4 * focus;
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

  double get _geometricTileSize {
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

  double get _focusTileSize =>
      focusAnimation.value * (Platform.isMobile ? 0.9 : 1.05) +
      (1 - focusAnimation.value) * 1;

  double get _pressTileSize =>
      pressAnimation.value * 1 + (1 - pressAnimation.value) * 0.9;

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
