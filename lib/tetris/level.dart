import 'dart:ui';

import 'package:skwer/colors.dart';

const kLevels = [
  Level(1, 0, Duration(milliseconds: 47 * 16), skRed, skRed),
  Level(2, 10, Duration(milliseconds: 42 * 16), skDarkGreen, skGreen),
  Level(3, 20, Duration(milliseconds: 37 * 16), skBlue, skCyan),
  Level(4, 30, Duration(milliseconds: 32 * 16), skDarkGreen, skYellow),
  Level(5, 40, Duration(milliseconds: 27 * 16), skRealRed, skOrange),
  Level(6, 50, Duration(milliseconds: 22 * 16), skPurple, skBlue),
  Level(7, 60, Duration(milliseconds: 14 * 16), skBlack, skGreen),
  Level(8, 70, Duration(milliseconds: 9 * 16), skBlack, skRed),
  Level(9, 100, Duration(milliseconds: 4 * 16), skBlack, skCyan),
];

class Level {
  final int value;
  final int score;
  final Duration stepDuration;
  final Color gradientColor;
  final Color borderColor;

  const Level(
    this.value,
    this.score,
    this.stepDuration,
    this.gradientColor,
    this.borderColor,
  );

  Level? get next {
    if (this == kLevels.last) {
      return null;
    }
    return kLevels[value];
  }
}
