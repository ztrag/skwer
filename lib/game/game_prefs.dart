import 'dart:math';

import 'package:flutter/foundation.dart';

const kNumTiles = [
  Point(3, 4),
  Point(3, 5),
  Point(4, 6),
  Point(4, 7),
  Point(5, 7),
  Point(5, 8),
  Point(6, 10),
  Point(6, 9),
  Point(6, 11),
];

class GamePrefs {
  static const int defaultTileLevel = 5;
  static const int defaultPuzzleSize = 7;

  final ValueNotifier<int> puzzleSize = ValueNotifier(defaultPuzzleSize);
  final ValueNotifier<Point<int>> _numTiles =
      ValueNotifier(kNumTiles[defaultTileLevel]);

  int _tileLevel = defaultTileLevel;

  ValueListenable<Point<int>> get numTiles => _numTiles;

  int get tileLevel => _tileLevel;

  set tileLevel(int level) {
    _tileLevel = level % kNumTiles.length;
    _numTiles.value = kNumTiles[_tileLevel];
  }
}
