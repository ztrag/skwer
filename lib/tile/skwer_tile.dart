import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/mosaic/color_wave.dart';
import 'package:skwer/mosaic/grid_mosaic.dart';
import 'package:skwer/mosaic/mosaic.dart';
import 'package:skwer/mosaic/rosetta_mosaic.dart';
import 'package:skwer/mosaic/transition_mosaic.dart';
import 'package:skwer/platform.dart';
import 'package:skwer/skwer/game_props.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_props.dart';
import 'package:skwer/tile/skwer_tile_skwer.dart';

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
  late final AnimationController skwerAnimationController;
  late final Animation<double> skwerAnimation;
  late final AnimationController pressAnimationController;
  late final Animation<double> pressAnimation;
  late final AnimationController highlightAnimationController;
  late final Animation<double> highlightAnimation;
  late final AnimationController focusAnimationController;
  late final Animation<double> focusAnimation;
  late final AnimationController solvedAnimationController;
  late final Animation<double> solvedAnimation;
  late final AnimationController activeAnimationController;
  late final Animation<double> activeAnimation;
  late final AnimationController puzzleHighlightAnimationController;
  late final Animation<double> puzzleHighlightAnimation;
  late final AnimationController mosaicTransitionAnimationController;
  late final Animation<double> mosaicTransitionAnimation;
  late final AnimationController rainbowAnimationController;
  late final Animation<double> rainbowAnimation;
  late final _SkwerTilePaint paint;
  final List<SkwerTileSkwer> skwerHistory = [];

  @override
  void initState() {
    super.initState();

    const puzzleStateDuration = Duration(milliseconds: 300);
    skwerAnimationController =
        AnimationController(duration: kColorWaveAnimationDuration, vsync: this);
    skwerAnimation =
        Tween(begin: 0.0, end: 1.0).animate(skwerAnimationController);
    pressAnimationController =
        AnimationController(duration: puzzleStateDuration, vsync: this);
    pressAnimation =
        CurveTween(curve: Curves.easeIn).animate(pressAnimationController);
    highlightAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    highlightAnimation =
        CurveTween(curve: Curves.ease).animate(highlightAnimationController);
    focusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 50),
      vsync: this,
    );
    focusAnimation =
        CurveTween(curve: Curves.ease).animate(focusAnimationController);
    solvedAnimationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    solvedAnimation =
        CurveTween(curve: Curves.ease).animate(solvedAnimationController);
    activeAnimationController =
        AnimationController(duration: puzzleStateDuration, vsync: this);
    activeAnimation =
        CurveTween(curve: Curves.ease).animate(activeAnimationController);
    puzzleHighlightAnimationController =
        AnimationController(duration: puzzleStateDuration, vsync: this);
    puzzleHighlightAnimation = CurveTween(curve: Curves.ease)
        .animate(puzzleHighlightAnimationController);
    mosaicTransitionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    mosaicTransitionAnimation = CurveTween(curve: Curves.ease)
        .animate(mosaicTransitionAnimationController);
    rainbowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    rainbowAnimation =
        Tween(begin: 0.0, end: 1.0).animate(rainbowAnimationController);
    rainbowAnimationController.value = 1;
    paint = _SkwerTilePaint(widget.props, widget.gameProps, this);

    onTileSkwerChanged();
    setImmediateState();
    widget.props.skwer.addListener(onTileSkwerChanged);
    widget.props.pressCounter.addListener(onPressed);
    widget.props.isHighlighted.addListener(onHighlighted);
    widget.props.isFocused.addListener(onFocused);
    widget.props.isActive.addListener(onActive);
    widget.gameProps.isSolved.addListener(onSolved);
    widget.gameProps.skwer.addListener(onGameSkwerChanged);
  }

  @override
  void dispose() {
    widget.props.skwer.removeListener(onTileSkwerChanged);
    widget.props.pressCounter.removeListener(onPressed);
    widget.props.isHighlighted.removeListener(onHighlighted);
    widget.props.isFocused.removeListener(onFocused);
    widget.props.isActive.removeListener(onActive);
    widget.gameProps.isSolved.removeListener(onSolved);
    widget.gameProps.skwer.removeListener(onGameSkwerChanged);
    skwerAnimationController.dispose();
    focusAnimationController.dispose();
    highlightAnimationController.dispose();
    pressAnimationController.dispose();
    activeAnimationController.dispose();
    solvedAnimationController.dispose();
    puzzleHighlightAnimationController.dispose();
    mosaicTransitionAnimationController.dispose();
    rainbowAnimationController.dispose();
    super.dispose();
  }

  void setImmediateState() {
    pressAnimationController.value = 1;
    highlightAnimationController.value = 0;
    solvedAnimationController.value = widget.gameProps.isSolved.value ? 1 : 0;
    activeAnimationController.value = widget.props.isActive.value ? 1 : 0;
    puzzleHighlightAnimationController.value = 0;
  }

  void onGameSkwerChanged() {
    final skwerDelta =
        widget.props.skwer.value.skwer - widget.gameProps.skwer.value;
    final hasPuzzleHighlight = skwerDelta < 0 || skwerDelta % 3 != 0;
    if (hasPuzzleHighlight) {
      puzzleHighlightAnimationController.forward();
    } else {
      puzzleHighlightAnimationController.reverse();
    }
    final hasRosetta = skwerDelta < -2;
    if (hasRosetta) {
      mosaicTransitionAnimationController.forward();
    } else {
      mosaicTransitionAnimationController.reverse();
    }
  }

  void onTileSkwerChanged() {
    onGameSkwerChanged();
    onHighlighted();
    final currentSkwer = widget.props.skwer.value;
    if (!currentSkwer.animateColor) {
      skwerHistory.clear();
    }
    if (skwerHistory.isNotEmpty &&
        currentSkwer.time.difference(skwerHistory.last.time) <
            const Duration(milliseconds: 16) &&
        skwerHistory.last.animateColor) {
      skwerHistory.removeLast();
    }
    skwerHistory.add(currentSkwer);

    if (!currentSkwer.animateColor) {
      skwerAnimationController.value = 1;
      setImmediateState();
    } else {
      skwerAnimationController.forward(from: 0);
    }
  }

  void onPressed() {
    pressAnimationController.forward(from: 0);
  }

  void onHighlighted() {
    if (widget.props.isHighlighted.value) {
      highlightAnimationController.forward();
    } else {
      highlightAnimationController.reverse();
    }
  }

  void onFocused() {
    if (widget.props.isFocused.value) {
      focusAnimationController.forward();
    } else {
      if (!widget.gameProps.hasPuzzle) {
        rainbowAnimationController.forward();
      }
      focusAnimationController.reverse();
    }
  }

  void onActive() {
    if (widget.props.isActive.value) {
      activeAnimationController.forward();
    } else {
      activeAnimationController.reverse();
    }
  }

  void onSolved() {
    if (widget.gameProps.isSolved.value) {
      solvedAnimationController.forward();
    } else {
      solvedAnimationController.reverse();
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
      child: RepaintBoundary(child: CustomPaint(painter: paint)),
    );
  }
}

class _SkwerTilePaint extends CustomPainter {
  static final Paint focusPaint = buildFocusPaint();

  final Mosaic grid = GridMosaic();
  final Mosaic rosetta = MosaicRosetta();
  late final TransitionMosaic transition = TransitionMosaic(grid, rosetta);

  final GameProps gameProps;
  final SkwerTileProps props;
  final _SkwerTileState state;

  _SkwerTilePaint(
    this.props,
    this.gameProps,
    this.state,
  ) : super(
          repaint: Listenable.merge([
            gameProps.skwer,
            gameProps.puzzle,
            gameProps.numTiles,
            props.skwer,
            props.hoverPosition,
            state.skwerAnimation,
            state.pressAnimation,
            state.highlightAnimation,
            state.focusAnimation,
            state.solvedAnimation,
            state.activeAnimation,
            state.puzzleHighlightAnimation,
            state.mosaicTransitionAnimation,
            state.rainbowAnimation,
          ]),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final x = 0.88 * geometricTileSize * focusTileSize * pressTileSize;
    canvas.translate(
      size.width * (1 - x) / 2,
      size.height * (1 - x) / 2,
    );
    size = Size(size.width * x, size.height * x);

    if (props.isFocused.value ||
        (state.highlightAnimation.value > 0 && props.isHighlighted.value)) {
      final x = size.width * 0.02;
      focusPaint.strokeWidth =
          size.width * (props.isFocused.value ? 0.16 : 0.13);
      focusPaint.color = Color.lerp(
          skTileColors[(props.skwer.value.skwer + 1) % 3],
          skBlack,
          props.isFocused.value
              ? 0.0
              : (props.skwer.value.skwer == 1 ? 0.25 : 0.4))!;
      canvas.drawRect(
        Rect.fromLTRB(x, x, size.width - x, size.height - x),
        focusPaint,
      );
    }

    currentGroup.paint(
      canvas,
      size,
      brightness * tileOpacity,
      state.pressAnimation.value,
      currentWaves,
      props.isFocused.value && props.isActive.value
          ? props.hoverPosition.value
          : null,
    );
  }

  double get brightness {
    final solved = state.solvedAnimation.value;
    final active = state.activeAnimation.value;
    final puzzle = state.puzzleHighlightAnimation.value;
    final highlight = state.highlightAnimation.value;
    final focus = state.focusAnimation.value;

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

  Mosaic get currentGroup {
    if (state.mosaicTransitionAnimation.value == 1) {
      return rosetta;
    } else if (state.mosaicTransitionAnimation.value == 0) {
      return grid;
    }
    transition.transition = state.mosaicTransitionAnimation.value;
    return transition;
  }

  static Paint buildFocusPaint() {
    final paint = Paint();
    paint.style = PaintingStyle.stroke;
    return paint;
  }

  double get geometricTileSize {
    final numTiles = max(gameProps.numTilesX, gameProps.numTilesY);
    final xNumTiles = tileSizeFromNumTiles(numTiles);
    final xPuzzle = gameProps.hasPuzzle && props.isActive.value ? 0.95 : 0.8;
    final xDist = 0.3 *
        xNumTiles *
        numTiles /
        (props.isActive.value && gameProps.hasPuzzle
            ? 0.1
            : cartesianDistFromCenter);
    final x = xPuzzle * min(1.0, pow(xDist, 0.7));
    return pow(x, 1.1).toDouble();
  }

  double get focusTileSize =>
      state.focusAnimation.value * (Platform.isMobile ? 0.9 : 1.05) +
      (1 - state.focusAnimation.value) * 1;

  double get pressTileSize =>
      state.pressAnimation.value * 1 + (1 - state.pressAnimation.value) * 0.9;

  double tileSizeFromNumTiles(int numTiles) {
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

  double get tileOpacity {
    if (Platform.isMobile) {
      if (gameProps.hasPuzzle) {
        return 1;
      }
      final x = min(1.0, 2 / cartesianDistFromCenter);
      return pow(x, 1).toDouble();
    }

    if (gameProps.hasPuzzle && props.isActive.value) {
      return 1;
    }
    final x = min(1.0, 5 / cartesianDistFromCenter);
    return pow(x, 1).toDouble();
  }

  double get cartesianDistFromCenter {
    final dx = props.index.x + 0.5 - gameProps.numTilesX / 2;
    final dy = props.index.y + 0.5 - gameProps.numTilesY / 2;
    return 1.0 * pow(dx * dx + dy * dy, 0.45);
  }

  List<ColorWave> get currentWaves {
    if (state.rainbowAnimation.value != 1) {
      return rainbowWave;
    }

    final waves = <ColorWave>[];
    final now = DateTime.now();

    var trim = false;
    final isFailed = state.skwerHistory.last.isFailed(props, gameProps);
    for (var i = state.skwerHistory.length - 1; i >= 0; i--) {
      if (trim && state.skwerHistory.length > 5) {
        state.skwerHistory.removeAt(0);
        continue;
      }

      final skwer = state.skwerHistory[i];
      var elapsed = now.difference(skwer.time);
      if (elapsed > kColorWaveAnimationDuration) {
        trim = true;
        elapsed = kColorWaveAnimationDuration;
      }
      var animation =
          elapsed.inMilliseconds / kColorWaveAnimationDuration.inMilliseconds;

      if (skwer.isFailed(props, gameProps)) {
        animation *= 0.7;
        if (!isFailed) {
          animation += 0.3 *
              (now.difference(state.skwerHistory.last.time).inMilliseconds /
                  kColorWaveAnimationDuration.inMilliseconds);
          animation = min(1, animation);
        }
      }

      waves.add(
        ColorWave(
          color: skTileColors[
              ((props.skwer.value.skwer == gameProps.skwer.value)
                      ? props.skwer.value.skwer
                      : skwer.skwer) %
                  3],
          animation: animation,
          rotate: skwer.animateWave,
          direction: getWaveDirectionFromTrigger(skwer.trigger),
        ),
      );
    }
    return waves;
  }

  Point<double>? getWaveDirectionFromTrigger(SkwerTileIndex? trigger) {
    if (trigger == null) {
      return null;
    }

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

  List<ColorWave> get rainbowWave {
    return [
      ColorWave(
        color: skTileColors[props.skwer.value.skwer % 3],
        animation: state.rainbowAnimation.value,
        rotate: true,
      ),
      ColorWave(
        color: rainbowColor,
        animation: 1,
        rotate: false,
      ),
    ];
  }

  Color get rainbowColor {
    return Color.lerp(
      skTileColors[(props.skwer.value.skwer + 1) % 3],
      skTileColors[(props.skwer.value.skwer + 2) % 3],
      0.25 + 0.5 * _random.nextDouble(),
    )!;
  }
}
