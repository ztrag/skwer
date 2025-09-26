import 'dart:math';

import 'package:skwer/platform.dart';
import 'package:skwer/tetris/game_props.dart';

class GameBoard {
  final int numTilesX;
  final int numTilesY;
  final int tileSize;

  GameBoard(this.numTilesX, this.numTilesY, this.tileSize);

  factory GameBoard.fromProps(GameProps props) {
    final size = props.size.value;
    final w = size.width;
    final h = min(size.height, 896);

    final boardSize = props.prefs.boardSize.value;
    final numTilesX = Platform.isMobile || w > 400
        ? boardSize
        : w * (boardSize + 0.75) ~/ 400;
    final int numTilesY;
    final int tileSize;

    if (Platform.isMobile || w < 400) {
      tileSize = w ~/ (numTilesX + 0.75);
      numTilesY = min(20, (h / tileSize - 0.75).floor());
    } else {
      final tileSizeMinX = 400 ~/ (numTilesX + 0.75);
      final expansionSize = max(0.0, h - tileSizeMinX * 20.75);
      numTilesY = min(20, (h / tileSizeMinX - 0.75).floor());
      tileSize = min(
        (h - min(expansionSize, kTopPanelHeight)) ~/ (numTilesY + 0.75),
        w ~/ (numTilesX + 0.75),
      );
    }

    return GameBoard(numTilesX, numTilesY, tileSize);
  }

  bool get isTooSmall => numTilesX < 3 || numTilesY < 5;
}
