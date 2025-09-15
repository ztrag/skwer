import 'dart:ui';

import 'package:skwer/tetris/tetramino.dart';
import 'package:skwer/tile/tile_index.dart';

export 'package:skwer/tetris/tetramino.dart';
export 'package:skwer/tile/tile_index.dart';

class GameTetramino {
  final Tetramino tetramino;
  final TileIndex position;
  final int rotation;
  final Color color;

  const GameTetramino(this.tetramino, this.position, this.rotation, this.color);

  GameTetramino rotate() {
    return GameTetramino(tetramino, position, (rotation + 1) % 4, color);
  }

  List<TileIndex> get tiles {
    return tetramino
        .points(rotation)
        .map((p) => position.translate(p.x, p.y))
        .toList(growable: false);
  }
}
