import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:skwer/mosaic/color_wave.dart';
import 'package:skwer/mosaic/mosaic_tile_painter.dart';
import 'package:skwer/tetris/game_tile_props.dart';

class GameTile extends StatefulWidget {
  final GameTileProps props;

  const GameTile({Key? key, required this.props}) : super(key: key);

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile>
    with SingleTickerProviderStateMixin {
  late Ticker ticker = createTicker(onTick);
  final ValueNotifier<bool> didInit = ValueNotifier(false);

  late final _Painter paint = _Painter(widget.props, didInit);

  @override
  void initState() {
    super.initState();
    ticker.start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final density = MediaQuery.of(context).devicePixelRatio;
    paint.density = density;
    return RepaintBoundary(child: CustomPaint(painter: paint));
  }

  void onTick(Duration elapsed) {
    if (paint.tilePainter.isLoaded) {
      ticker.stop();
      didInit.value = true;
    }
  }
}

class _Painter extends CustomPainter {
  final Paint dropHintPaint = Paint();
  final MosaicTilePainter tilePainter = MosaicTilePainter(3);

  final GameTileProps props;

  double density = 0.0;

  _Painter(this.props, Listenable didInit)
      : super(
          repaint: Listenable.merge(
            [
              props.color,
              props.dropHintColor,
              didInit,
            ],
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    if (!tilePainter.isLoaded) {
      return;
    }

    const x = 0.88;
    canvas.translate(
      size.width * (1 - x) / 2,
      size.height * (1 - x) / 2,
    );
    size = Size(size.width * x, size.height * x);

    final dropHintColor = props.dropHintColor.value;
    if (dropHintColor != null) {
      dropHintPaint.color = dropHintColor;
      canvas.drawRect(
          Rect.fromLTRB(
              0, (size.height * 0.95).floorToDouble(), size.width, size.height),
          dropHintPaint);
    }

    final color = props.color.value;
    if (color != null) {
      tilePainter.paint(
        canvas: canvas,
        size: size,
        density: density,
        waves: [
          ColorWave(
            color: color,
            animation: 0.0,
            rotate: false,
            direction: const Point(0.0, 0.0),
          )
        ],
        seed: (props.index.hashCode + 1) * 0.001,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
