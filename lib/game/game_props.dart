import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_props.dart';

class GameProps {
  final int skwer;
  final int numTilesX;
  final int numTilesY;

  final Map<SkwerTileIndex, SkwerTileProps> skwerTiles =
      <SkwerTileIndex, SkwerTileProps>{};

  GameProps._({
    this.skwer = 0,
    this.numTilesX = 0,
    this.numTilesY = 0,
  }) {
    for (var x = 0; x < numTilesX; x++) {
      for (var y = 0; y < numTilesY; y++) {
        final tileIndex = SkwerTileIndex(x, y);
        skwerTiles[tileIndex] = SkwerTileProps(index: tileIndex);
      }
    }
  }

  factory GameProps() => GameProps._();

  factory GameProps.resize({
    required GameProps props,
    required int numTilesX,
    required int numTilesY,
  }) =>
      GameProps._(
        skwer: props.skwer,
        numTilesX: numTilesX,
        numTilesY: numTilesY,
      );
}
