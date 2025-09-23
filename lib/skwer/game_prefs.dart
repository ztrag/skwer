import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:skwer/platform.dart';
import 'package:skwer/skwer/game_board.dart';

const kMobileBoards = [
  GameBoard(Point(4, 6), Point(2, 2)),
  GameBoard(Point(4, 7), Point(2, 3)),
  GameBoard(Point(5, 7), Point(3, 3)),
  GameBoard(Point(5, 8), Point(3, 4)),
  GameBoard(Point(6, 10), Point(4, 4)),
  GameBoard(Point(6, 9), Point(4, 5)),
];

const kDesktopZoneSizes = [
  Point(2, 2),
  Point(3, 2),
  Point(3, 3),
  Point(4, 2),
  Point(4, 3),
  Point(4, 4),
  Point(5, 2),
  Point(5, 3),
  Point(5, 4),
  Point(5, 5),
];

class GamePrefs {
  static const int defaultPuzzleSize = 6;
  static const int defaultMobileBoardLevel = 3;
  static const int defaultDesktopZoneLevel = 9;

  final ValueNotifier<int> _puzzleSize = ValueNotifier(defaultPuzzleSize);

  int mobileBoardLevel = defaultMobileBoardLevel;

  int _desktopZoneLevel = defaultDesktopZoneLevel;

  ValueListenable<int> get puzzleSize => _puzzleSize;

  int get desktopZoneLevel => _desktopZoneLevel;

  set desktopZoneLevel(int level) {
    _desktopZoneLevel = level % kDesktopZoneSizes.length;
  }

  void setPuzzleSize(int size) {
    _puzzleSize.value = size;
  }

  GameBoard? get board {
    if (!Platform.isMobile) {
      return null;
    }
    return kMobileBoards[mobileBoardLevel % kMobileBoards.length];
  }

  Point<int>? get zoneSize {
    if (Platform.isMobile) {
      return null;
    }
    return kDesktopZoneSizes[_desktopZoneLevel % kDesktopZoneSizes.length];
  }
}
