import 'dart:ui';

class ShaderCache {
  static final Map<String, Future<Paint>> _map = {};

  static Future<Paint> load(String shader) {
    return _map[shader] ??= _load(shader);
  }

  static Future<Paint> _load(String shader) async {
    final program = await FragmentProgram.fromAsset(shader);
    final s = program.fragmentShader();
    final p = Paint();
    p.shader = s;
    return p;
  }
}
