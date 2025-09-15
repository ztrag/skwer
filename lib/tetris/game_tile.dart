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
  late final _Paint paint = _Paint(widget.props);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: CustomPaint(painter: paint));
  }
}

class _Paint extends CustomPainter {
  final Mosaic mosaic = GridMosaic(4);

  final GameTileProps props;

  _Paint(this.props) : super(repaint: props.color);

  @override
  void paint(Canvas canvas, Size size) {
    const x = 0.88;
    canvas.translate(
      size.width * (1 - x) / 2,
      size.height * (1 - x) / 2,
    );
    size = Size(size.width * x, size.height * x);

    final color = props.color.value;
    if (color == null) {
      return;
    }

    mosaic.paint(
      canvas,
      size,
      0.8,
      1,
      [ColorWave(color: color, animation: 0, rotate: false)],
      null,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
