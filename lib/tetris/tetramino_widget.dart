import 'package:flutter/material.dart';
import 'package:skwer/tetris/game_tetramino.dart';
import 'package:skwer/tetris/game_tile.dart';
import 'package:skwer/tetris/game_tile_props.dart';

class TetraminoWidget extends StatelessWidget {
  final Tetramino tetramino;

  const TetraminoWidget({Key? key, required this.tetramino}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final positions = tetramino.points(0);
    int? minX;
    int? minY;
    int? maxX;
    int? maxY;
    final indices = positions.map((p) => TileIndex(p.x, p.y)).toSet();
    for (final position in positions) {
      if (minX == null || minX > position.x) {
        minX = position.x;
      }
      if (maxX == null || maxX < position.x) {
        maxX = position.x;
      }
      if (minY == null || minY > position.y) {
        minY = position.y;
      }
      if (maxY == null || maxY < position.y) {
        maxY = position.y;
      }
    }
    final tiles = <List<Widget>>[];
    for (var y = minY!; y <= maxY!; y++) {
      tiles.add(<Widget>[]);
      for (var x = minX!; x <= maxX!; x++) {
        final tileIndex = TileIndex(x, y);
        final props = GameTileProps(tileIndex);
        props.color.value = tetramino.color;
        tiles.last.add(
          SizedBox(
            width: 25,
            height: 25,
            child: indices.contains(tileIndex)
                ? GameTile(props: props)
                : const SizedBox.shrink(),
          ),
        );
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tiles
          .map(
            (row) => Row(children: row.toList()),
          )
          .toList(),
    );
  }
}
