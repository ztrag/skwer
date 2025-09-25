import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/mosaic/color_wave.dart';
import 'package:skwer/mosaic/mosaic_tile_painter.dart';
import 'package:skwer/platform.dart';
import 'package:skwer/skwer/game_props.dart';
import 'package:skwer/tile/skwer_tile_props.dart';
import 'package:skwer/tile/skwer_tile_skwer.dart';
import 'package:skwer/tile/tile_index.dart';

const _skwer = 0;
const _press = 1;
const _highlight = 2;
const _focus = 3;
const _solved = 4;
const _active = 5;
const _puzzleHighlight = 6;
const _mode = 7;

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
  static const puzzleStateDuration = Duration(milliseconds: 300);
  late Ticker ticker = createTicker(onTick);
  final ValueNotifier<bool> didInit = ValueNotifier(false);

  late final Map<int, AnimationController> animationControllers = {
    _skwer:
        AnimationController(duration: kColorWaveAnimationDuration, vsync: this),
    _press: AnimationController(duration: puzzleStateDuration, vsync: this),
    _highlight: AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    ),
    _focus: AnimationController(
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 50),
      vsync: this,
    ),
    _solved: AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    ),
    _active: AnimationController(duration: puzzleStateDuration, vsync: this),
    _puzzleHighlight:
        AnimationController(duration: puzzleStateDuration, vsync: this),
    _mode: AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this),
  };
  late final List<Animation<double>> animations = [
    Tween(begin: 0.0, end: 1.0).animate(animationControllers[_skwer]!),
    CurveTween(curve: Curves.easeIn).animate(animationControllers[_press]!),
    CurveTween(curve: Curves.ease).animate(animationControllers[_highlight]!),
    CurveTween(curve: Curves.ease).animate(animationControllers[_focus]!),
    CurveTween(curve: Curves.ease).animate(animationControllers[_solved]!),
    CurveTween(curve: Curves.ease).animate(animationControllers[_active]!),
    CurveTween(curve: Curves.ease)
        .animate(animationControllers[_puzzleHighlight]!),
    CurveTween(curve: Curves.ease).animate(animationControllers[_mode]!),
  ];
  late final _SkwerTilePaint paint;
  final List<SkwerTileSkwer> skwerHistory = [];
  double density = 0.0;

  @override
  void initState() {
    super.initState();
    paint = _SkwerTilePaint(this);
    ticker.start();

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
    for (final controller in animationControllers.values) {
      controller.dispose();
    }
    ticker.dispose();
    super.dispose();
  }

  void setImmediateState() {
    animationControllers[_press]!.value = 1;
    animationControllers[_highlight]!.value = 0;
    animationControllers[_solved]!.value =
        widget.gameProps.isSolved.value ? 1 : 0;
    animationControllers[_active]!.value = widget.props.isActive.value ? 1 : 0;
    animationControllers[_puzzleHighlight]!.value = 0;
  }

  void onGameSkwerChanged() {
    final skwerDelta =
        widget.props.skwer.value.skwer - widget.gameProps.skwer.value;
    final hasPuzzleHighlight = skwerDelta < 0 || skwerDelta % 3 != 0;
    if (hasPuzzleHighlight) {
      animationControllers[_puzzleHighlight]!.forward();
    } else {
      animationControllers[_puzzleHighlight]!.reverse();
    }
    final hasRosetta = skwerDelta < -2;
    if (hasRosetta) {
      animationControllers[_mode]!.forward();
    } else {
      animationControllers[_mode]!.reverse();
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
      animationControllers[_skwer]!.value = 1;
      setImmediateState();
    } else {
      animationControllers[_skwer]!.forward(from: 0);
    }
  }

  void onPressed() {
    animationControllers[_press]!.forward(from: 0);
  }

  void onHighlighted() {
    if (widget.props.isHighlighted.value) {
      animationControllers[_highlight]!.forward();
    } else {
      animationControllers[_highlight]!.reverse();
    }
  }

  void onFocused() {
    if (widget.props.isFocused.value) {
      animationControllers[_focus]!.forward();
    } else {
      animationControllers[_focus]!.reverse();
    }
  }

  void onActive() {
    if (widget.props.isActive.value) {
      animationControllers[_active]!.forward();
    } else {
      animationControllers[_active]!.reverse();
    }
  }

  void onSolved() {
    if (widget.gameProps.isSolved.value) {
      animationControllers[_solved]!.forward();
    } else {
      animationControllers[_solved]!.reverse();
    }
  }

  void onTick(Duration elapsed) {
    if (paint.tilePainter.isLoaded) {
      ticker.stop();
      didInit.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    density = MediaQuery.of(context).devicePixelRatio;
    return MouseRegion(
      onHover: (hover) =>
          widget.props.hoverPosition.value = hover.localPosition,
      onEnter: (enter) =>
          widget.props.hoverPosition.value = enter.localPosition,
      onExit: (exit) => widget.props.hoverPosition.value = null,
      child: RepaintBoundary(child: CustomPaint(painter: paint)),
    );
  }

  Listenable repaint() {
    return Listenable.merge([
      widget.gameProps.skwer,
      widget.gameProps.puzzle,
      widget.gameProps.board,
      widget.props.skwer,
      widget.props.hoverPosition,
      didInit,
      ...animations
    ]);
  }
}

class _SkwerTilePaint extends CustomPainter {
  static final Paint focusPaint = Paint()..style = PaintingStyle.stroke;
  final MosaicTilePainter tilePainter = MosaicTilePainter(5);

  final _SkwerTileState state;

  _SkwerTilePaint(this.state) : super(repaint: state.repaint());

  @override
  void paint(Canvas canvas, Size size) {
    if (!tilePainter.isLoaded) {
      return;
    }

    final x = 0.9 * geometricTileSize * focusTileSize * pressTileSize;
    canvas.translate(
      size.width * (1 - x) / 2,
      size.height * (1 - x) / 2,
    );
    size = Size(size.width * x, size.height * x);

    if (props.isFocused.value ||
        (animations[_highlight].value > 0 && props.isHighlighted.value)) {
      final x = -size.width * 0.035;
      focusPaint.strokeWidth =
          size.width * (props.isFocused.value ? 0.07 : 0.05);
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

    tilePainter.paint(
      canvas: canvas,
      size: size,
      density: state.density,
      waves: currentWaves,
      seed: (props.index.hashCode + 1) * 0.001,
      brightness: brightness * tileOpacity * 0.9,
      mode: animations[_mode].value,
      flash: 1.0 - animations[_press].value,
    );
    // TODO paint hover position...
    //   props.isFocused.value && props.isActive.value
    //       ? props.hoverPosition.value
    //       : null,
    // );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _SkwerTilePaint;
  }

  double get brightness {
    final solved = animations[_solved].value;
    final active = animations[_active].value;
    final puzzle = animations[_puzzleHighlight].value;
    final highlight = animations[_highlight].value;
    final focus = animations[_focus].value;

    final z = (solved * active) * 1 +
        (solved * (1 - active)) * 0.7 +
        ((1 - solved) * active * puzzle) * 1.0 +
        ((1 - solved) * active * (1 - puzzle)) * 0.6 +
        ((1 - solved) * (1 - active) * puzzle) * 0.75 +
        ((1 - solved) * (1 - active) * (1 - puzzle)) * 0.2;
    final y = z * (1 - highlight * puzzle) + 1.05 * highlight * puzzle;
    return y * (1 - focus) + 1.4 * focus;
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
      animations[_focus].value * (Platform.isMobile ? 0.9 : 1.05) +
      (1 - animations[_focus].value) * 1;

  double get pressTileSize =>
      animations[_press].value * 1 + (1 - animations[_press].value) * 0.9;

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
    final waves = <ColorWave>[];
    final now = DateTime.now();

    final isFailed = state.skwerHistory.last.isFailed(props, gameProps);
    for (var i = state.skwerHistory.length - 1; i >= 0; i--) {
      if (state.skwerHistory.length > 3) {
        state.skwerHistory.removeAt(0);
        continue;
      }

      final skwer = state.skwerHistory[i];
      var elapsed = now.difference(skwer.time);
      if (elapsed > kColorWaveAnimationDuration) {
        elapsed = kColorWaveAnimationDuration;
      }
      var animation =
          elapsed.inMilliseconds / kColorWaveAnimationDuration.inMilliseconds;

      if (skwer.isFailed(props, gameProps)) {
        animation *= 0.5;
        if (!isFailed) {
          animation += 0.5 *
              (now.difference(state.skwerHistory.last.time).inMilliseconds /
                  kColorWaveAnimationDuration.inMilliseconds);
          animation = min(1, animation);
        }
      }

      waves.add(
        ColorWave(
          color: skTileColors[
              ((props.skwer.value.skwer == gameProps.skwer.value &&
                          gameProps.isSolved.value)
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

  Point<double> getWaveDirectionFromTrigger(TileIndex? trigger) {
    if (trigger == null) {
      return const Point(0, 0);
    }

    final target = props.index;
    return Point(
      target.x > trigger.x
          ? 1.0
          : target.x < trigger.x
              ? -1.0
              : 0.0,
      target.y > trigger.y
          ? 1.0
          : target.y < trigger.y
              ? -1.0
              : 0.0,
    );
  }

  GameProps get gameProps => state.widget.gameProps;

  SkwerTileProps get props => state.widget.props;

  List<Animation<double>> get animations => state.animations;
}
