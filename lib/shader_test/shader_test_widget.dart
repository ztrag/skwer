import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:skwer/colors.dart';

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

  double fract(double x) {
    return x - x.floor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!didInit) {
      return;
    }
    // shader.setFloat(0, time.value.inMilliseconds / 1000.0);
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, fract(0.1 * time.value.inMilliseconds / 100.0));
    // shader.setFloat(2, 1);
    shader.setFloat(3, fract(0.1 * time.value.inMilliseconds / 200.0));
    // shader.setFloat(3, 0);

    const color1 = skGreen;
    const color2 = skRed;
    shader.setFloat(4, color1.r);
    shader.setFloat(5, color1.g);
    shader.setFloat(6, color1.b);
    shader.setFloat(7, color2.r);
    shader.setFloat(8, color2.g);
    shader.setFloat(9, color2.b);
    shader.setFloat(10, 1.0);
    shader.setFloat(11, 0.0);

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
