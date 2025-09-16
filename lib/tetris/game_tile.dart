import 'package:flutter/material.dart';
import 'package:skwer/mosaic/color_wave.dart';
import 'package:skwer/mosaic/grid_mosaic.dart';
import 'package:skwer/mosaic/mosaic.dart';
import 'package:skwer/tetris/game_tile_props.dart';

class GameTile extends StatefulWidget {
  final GameTileProps props;

  const GameTile({Key? key, required this.props}) : super(key: key);

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> {
  late final _Painter paint = _Painter(widget.props);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: CustomPaint(painter: paint));
  }
}

class _Painter extends CustomPainter {
  final Mosaic mosaic = GridMosaic(3);
  final Paint dropHintPaint = Paint();

  final GameTileProps props;

  _Painter(this.props)
      : super(repaint: Listenable.merge([props.color, props.dropHintColor]));

  @override
  void paint(Canvas canvas, Size size) {
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
      mosaic.paint(
        canvas,
        size,
        0.8,
        1,
        [ColorWave(color: color, animation: 0, rotate: false)],
        null,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
