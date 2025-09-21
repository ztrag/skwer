import 'dart:ui';

class ShaderCache {
  static final Map<String, Future<FragmentShader>> _map = {};

  static Future<FragmentShader> load(String shader) {
    return _map[shader] ??= _load(shader);
  }

  static Future<FragmentShader> _load(String shader) async {
    final program = await FragmentProgram.fromAsset(shader);
    return program.fragmentShader();
  }
}
