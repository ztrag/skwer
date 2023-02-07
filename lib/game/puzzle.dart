import 'dart:math';

import 'package:skwer/game/game_rotation.dart';
import 'package:skwer/game/game_zone.dart';
import 'package:skwer/tile/skwer_tile_index.dart';

class Puzzle {
  static final Random _random = Random();

  final List<GameRotation> rotations;

  Puzzle(GameZone zone, int size)
      : rotations = _calcRandomRotations(size, zone);

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
