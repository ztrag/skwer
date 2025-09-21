import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:skwer/tetris/game_tile_props.dart';
import 'package:skwer/util/shader_cache.dart';

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
    return RepaintBoundary(child: CustomPaint(painter: paint));
  }

  void onTick(Duration elapsed) {
    if (paint._paint.shader != null) {
      ticker.stop();
      didInit.value = true;
    }
  }
}

class _Painter extends CustomPainter {
  final Paint dropHintPaint = Paint();

  final GameTileProps props;

  final Paint _paint = Paint();
  bool hasPainted = false;

  _Painter(this.props, Listenable didInit)
      : super(
          repaint: Listenable.merge(
            [
              props.color,
              props.dropHintColor,
              didInit,
            ],
          ),
        ) {
    load();
  }

  void load() async {
    _paint.shader = await ShaderCache.load('shaders/skwer_tile.frag');
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_paint.shader == null) {
      return;
    }
    hasPainted = true;

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
      _paintShader(canvas, color, size);
    }
  }

  void _paintShader(Canvas canvas, Color color, Size size) {
    int i = 0;
    final shader = _paint.shader as FragmentShader;
    shader.setFloat(i++, (props.index.hashCode + 1) * 0.001);
    shader.setFloat(i++, size.width);
    shader.setFloat(i++, size.height);
    shader.setFloat(i++, 3.0);
    shader.setFloat(i++, 1.0);
    shader.setFloat(i++, 0.0);
    shader.setFloat(i++, 0.0);

    shader.setFloat(i++, color.r);
    shader.setFloat(i++, color.g);
    shader.setFloat(i++, color.b);

    // Fill missing waves. Shader does not handle dynamic array uniforms.
    for (int j = 0; j < 3; j++) {
      shader.setFloat(i++, color.r);
      shader.setFloat(i++, color.g);
      shader.setFloat(i++, color.b);
    }
    for (int j = 0; j < 4; j++) {
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
