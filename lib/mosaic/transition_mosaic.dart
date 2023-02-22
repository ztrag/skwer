import 'package:skwer/mosaic/mosaic.dart';
import 'package:skwer/mosaic/mosaic_tile.dart';
import 'package:skwer/mosaic/transition_mosaic_tile.dart';

class TransitionMosaic extends Mosaic {
  final Mosaic mosaicA;
  final Mosaic mosaicB;

  List<MosaicTile>? _tiles;
  double transition = 0;

  TransitionMosaic(this.mosaicA, this.mosaicB);

  @override
  List<MosaicTile> get tiles {
    _tiles ??= _buildTiles();
    for (final tile in _tiles!) {
      (tile as TransitionMosaicTile).transition = transition;
    }
    return _tiles!;
  }

  List<MosaicTile> _buildTiles() {
    final tiles = <MosaicTile>[];
    final remaining = [...mosaicB.tiles];
    for (final tile in mosaicA.tiles) {
      final match = _popClosest(tile, remaining);
      tiles.add(TransitionMosaicTile(tile, match));
    }
    for (final tile in remaining) {
      tiles.add(
        TransitionMosaicTile(
          MosaicTile(List.generate(4, (_) => tile.position)),
          tile,
        ),
      );
    }
    return tiles;
  }

  MosaicTile _popClosest(MosaicTile target, List<MosaicTile> tiles) {
    if (tiles.isEmpty) {
      return MosaicTile([target.position]);
    }

    var closest = tiles.first;
    var closestDistance = (closest.position - target.position).magnitude;

    for (final tile in tiles) {
      final distance = (tile.position - target.position).magnitude;
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = tile;
      }
    }

    tiles.remove(closest);
    return closest;
  }
}
