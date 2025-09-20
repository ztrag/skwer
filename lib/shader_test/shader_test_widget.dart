import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ShaderTestWidget extends StatefulWidget {
  const ShaderTestWidget({Key? key}) : super(key: key);

  @override
  State<ShaderTestWidget> createState() => _ShaderTestWidgetState();
}

class _ShaderTestWidgetState extends State<ShaderTestWidget> {
  final ValueNotifier<Duration> time = ValueNotifier(Duration.zero);
  late final _ShaderPainter painter = _ShaderPainter(time);
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    painter.load();
    ticker = Ticker(_update);
    ticker.start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // const MenuBackground(),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              // child: Center(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       AspectRatio(
              //         aspectRatio: 1,
              //         child: GameTile(
              //             props: GameTileProps(const TileIndex(0, 0))
              //               ..color.value = skRed),
              //       ),
              //       AspectRatio(
              //         aspectRatio: 1,
              //         child: RepaintBoundary(
              //           child: CustomPaint(painter: painter),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              child: RepaintBoundary(
                child: CustomPaint(painter: painter),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _update(Duration elapsed) {
    time.value = elapsed;
  }
}

class _ShaderPainter extends CustomPainter {
  final ValueNotifier<Duration> time;
  final Paint _paint = Paint();
  late final FragmentProgram program;
  late final FragmentShader shader;
  bool didInit = false;

  _ShaderPainter(this.time) : super(repaint: time);

  void load() async {
    program = await FragmentProgram.fromAsset('shaders/test-shader.frag');
    shader = program.fragmentShader();
    _paint.shader = shader;
    didInit = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!didInit) {
      return;
    }
    shader.setFloat(0, time.value.inMilliseconds / 1000.0);
    shader.setFloat(1, size.width);
    shader.setFloat(2, size.height);
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
