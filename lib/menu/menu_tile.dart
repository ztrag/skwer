import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/menu/menu_props.dart';
import 'package:skwer/menu/menu_tile_props.dart';

class MenuTile extends StatefulWidget {
  static final Random _random = Random();
  final double colorD1;

  final MenuProps gameProps;
  final MenuTileProps props;

  MenuTile({Key? key, required this.props, required this.gameProps})
      : colorD1 = d1,
        super(key: key);

  @override
  State<MenuTile> createState() => _MenuTileState();

  static double get d1 {
    const x = 0.6;
    return (0.95 - x / 2 + x * _random.nextDouble());
  }
}

class _MenuTileState extends State<MenuTile>
    with TickerProviderStateMixin {
  late final _MenuTilePainter painter = _MenuTilePainter(this);
  late final AnimationController colorAnimationController;
  late final Animation<double> colorAnimation;
  late Color previousColor;
  late Color currentColor;

  @override
  void initState() {
    super.initState();

    previousColor = getColorD1(widget.props.color.value);
    currentColor = previousColor;
    colorAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    colorAnimation =
        Tween(begin: 0.0, end: 1.0).animate(colorAnimationController);
    widget.props.color.addListener(_onColorChanged);
  }

  @override
  void dispose() {
    colorAnimationController.dispose();
    widget.props.color.removeListener(_onColorChanged);
    super.dispose();
  }

  void _onColorChanged() {
    previousColor =
        Color.lerp(previousColor, currentColor, colorAnimation.value)!;
    currentColor = getColorD1(widget.props.color.value);

    colorAnimationController.forward(from: 0);
  }

  Color getColorD1(Color color) {
    if (color.computeLuminance() < 0.1) {
      return color;
    }
    return widget.colorD1 > 1
        ? Color.lerp(color, skWhite, widget.colorD1 - 1)!
        : Color.lerp(color, skBlack, 1 - widget.colorD1)!;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (hover) =>
          widget.props.hoverPosition.value = hover.localPosition,
      onEnter: (enter) =>
          widget.props.hoverPosition.value = enter.localPosition,
      onExit: (exit) => widget.props.hoverPosition.value = null,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: painter,
        ),
      ),
    );
  }
}

class _MenuTilePainter extends CustomPainter {
  static final Paint _paint = createPaint();

  final _MenuTileState state;

  _MenuTilePainter(this.state)
      : super(
          repaint: Listenable.merge([
            state.colorAnimation,
            state.widget.props.isFocused,
          ]),
        );

  @override
  void paint(Canvas canvas, Size size) {
    _paint.style = PaintingStyle.fill;
    _paint.color = Color.lerp(
      state.previousColor,
      state.currentColor,
      state.colorAnimation.value,
    )!;
    var x = tileSize;
    canvas.drawRect(getDrawRect(size, x), _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  double get tileSize {
    final numTiles = min(
      state.widget.gameProps.numTilesX,
      state.widget.gameProps.numTilesY,
    );
    final xDist = 0.2 * numTiles / cartesianDistFromCenter;
    final x = 0.75 * min(1.0, pow(xDist, 3));
    return pow(x, 1.1).toDouble();
  }

  double get cartesianDistFromCenter {
    final dx =
        state.widget.props.index.x + 0.5 - state.widget.gameProps.numTilesX / 2;
    final dy =
        state.widget.props.index.y + 0.5 - state.widget.gameProps.numTilesY / 2;
    return 1.0 * pow(dx * dx + dy * dy, 0.4);
  }

  Rect getDrawRect(Size size, double tileSize) {
    final rectSize = size * tileSize;
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: rectSize.width,
      height: rectSize.height,
    );
  }

  static Paint createPaint() {
    return Paint();
  }
}
