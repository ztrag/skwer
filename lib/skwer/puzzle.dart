import 'dart:math';

import 'package:skwer/skwer/game_rotation.dart';
import 'package:skwer/skwer/game_zone.dart';
import 'package:skwer/tile/skwer_tile_index.dart';

class Puzzle {
  static final Random _random = Random();

  final GameZone zone;
  final List<GameRotation> rotations;

  Puzzle._(this.zone, this.rotations);

  factory Puzzle(GameZone zone, int size) =>
      Puzzle._(zone, _calcRandomRotations(size, zone));

  factory Puzzle.add(Puzzle puzzle) => Puzzle._(puzzle.zone, [
        ...puzzle.rotations,
        GameRotation(index: _getRandomIndex(puzzle.zone), delta: -1),
      ]);

  static List<GameRotation> _calcRandomRotations(int size, GameZone zone) =>
      List.generate(
        size,
        (_) => GameRotation(
          index: _getRandomIndex(zone),
          delta: -1,
        ),
      );

  static SkwerTileIndex _getRandomIndex(GameZone zone) => SkwerTileIndex(
        zone.start.x + _random.nextInt(zone.size.x),
        zone.start.y + _random.nextInt(zone.size.y),
      );
}
