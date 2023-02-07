import 'package:skwer/mosaic/mosaic_group.dart';
import 'package:skwer/mosaic/mosaic_tile.dart';
import 'package:skwer/mosaic/mosaic_transition_tile.dart';

class MosaicGroupTransition extends MosaicGroup {
  final MosaicGroup groupA;
  final MosaicGroup groupB;

  List<MosaicTile>? _tiles;
  int dir = 1;

  MosaicGroupTransition(this.groupA, this.groupB);

  @override
  List<MosaicTile> get tiles {
    _tiles ??= _buildTiles();
    for (final tile in _tiles!) {
      (tile as MosaicTransitionTile).dir = dir;
    }
    return _tiles!;
  }

  List<MosaicTile> _buildTiles() {
    final tiles = <MosaicTile>[];
    final remaining = [...groupB.tiles];
    for (final tile in groupA.tiles) {
      final match = _popClosest(tile, remaining);
      tiles.add(MosaicTransitionTile(tile, match));
    }
    for (final tile in remaining) {
      tiles.add(MosaicTransitionTile(MosaicTile([tile.position]), tile));
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
