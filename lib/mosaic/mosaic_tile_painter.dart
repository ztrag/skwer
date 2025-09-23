import 'dart:ui';

import 'package:skwer/mosaic/color_wave.dart';
import 'package:skwer/util/shader_cache.dart';

class MosaicTilePainter {
  final int n;

  Paint? _paint;

  MosaicTilePainter(this.n) {
    _load();
  }

  void _load() async {
    _paint = await ShaderCache.load('shaders/mosaic_tile_$n.frag');
  }

  bool get isLoaded => _paint != null;

  void paint({
    required Canvas canvas,
    required Size size,
    required List<ColorWave> waves,
    required double seed,
    int n = 5,
    double brightness = 1.0,
    double mode = 0.0,
    double flash = 0.0,
  }) {
    int i = 0;
    final shader = _paint!.shader as FragmentShader;
    shader.setFloat(i++, seed);
    shader.setFloat(i++, size.width);
    shader.setFloat(i++, size.height);
    shader.setFloat(i++, n * 1.0);
    shader.setFloat(i++, brightness);
    shader.setFloat(i++, mode);
    shader.setFloat(i++, flash);

    for (final wave in waves) {
      shader.setFloat(i++, wave.color.r);
      shader.setFloat(i++, wave.color.g);
      shader.setFloat(i++, wave.color.b);
    }
    // Fill missing waves. Shader does not handle dynamic array uniforms.
    for (int j = 0; j < (4 - waves.length); j++) {
      shader.setFloat(i++, waves.last.color.r);
      shader.setFloat(i++, waves.last.color.g);
      shader.setFloat(i++, waves.last.color.b);
    }
    for (final wave in waves) {
      shader.setFloat(i++, wave.direction.x);
      shader.setFloat(i++, wave.direction.y);
      shader.setFloat(i++, wave.animation);
      shader.setFloat(i++, wave.rotate ? wave.animation : 0.0);
    }
    // Fill missing waves. Shader does not handle dynamic array uniforms.
    for (int j = 0; j < (4 - waves.length); j++) {
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 1.0);
      shader.setFloat(i++, 1.0);
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _paint!,
    );
  }
}
