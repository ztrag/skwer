import 'package:skwer/tetris/tetramino.dart';
import 'package:skwer/tile/tile_index.dart';

export 'package:skwer/tetris/tetramino.dart';
export 'package:skwer/tile/tile_index.dart';

class GameTetramino {
  final Tetramino tetramino;
  final TileIndex position;
  final int rotation;

  const GameTetramino(this.tetramino, this.position, this.rotation);

  GameTetramino rotate() {
    return GameTetramino(tetramino, position, (rotation + 1) % 4);
  }

  GameTetramino translate(int x, int y) {
    return GameTetramino(tetramino, position.translate(x, y), rotation);
  }

  GameTetramino step() {
    return GameTetramino(tetramino, position.translate(0, 1), rotation);
  }

  List<TileIndex> get tiles {
    return tetramino
        .points(rotation)
        .map((p) => position.translate(p.x, p.y))
        .toList(growable: false);
  }
}
