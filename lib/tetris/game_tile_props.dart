import 'package:flutter/material.dart';
import 'package:skwer/tile/tile_index.dart';

class GameTileProps {
  final TileIndex index;

  final ValueNotifier<Color?> color = ValueNotifier(null);

  GameTileProps(this.index);
}
