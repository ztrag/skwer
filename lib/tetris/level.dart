import 'dart:ui';

import 'package:skwer/colors.dart';

const kLevels = [
  Level(1, 0, Duration(milliseconds: 48 * 16), skRed),
  Level(2, 10, Duration(milliseconds: 43 * 16), skGreen),
  Level(3, 20, Duration(milliseconds: 38 * 16), skPurple),
  Level(4, 30, Duration(milliseconds: 33 * 16), skYellow),
  Level(5, 40, Duration(milliseconds: 28 * 16), skBlue),
  Level(6, 50, Duration(milliseconds: 23 * 16), skOrange),
  Level(7, 60, Duration(milliseconds: 18 * 16), skCyan),
  Level(8, 70, Duration(milliseconds: 13 * 16), skBlack),
  Level(9, 100, Duration(milliseconds: 5 * 16), skRed),
];

class Level {
  final int value;
  final int score;
  final Color color;
  final Duration stepDuration;

  const Level(this.value, this.score, this.stepDuration, this.color);

  Level? get next {
    if (this == kLevels.last) {
      return null;
    }
    return kLevels[value];
  }
}
