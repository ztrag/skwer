const kLevels = [
  Level(1, 0, Duration(milliseconds: 750)),
  Level(2, 5, Duration(milliseconds: 677)),
  Level(3, 10, Duration(milliseconds: 605)),
  Level(4, 15, Duration(milliseconds: 533)),
  Level(5, 20, Duration(milliseconds: 461)),
  Level(6, 25, Duration(milliseconds: 388)),
  Level(7, 30, Duration(milliseconds: 316)),
  Level(8, 35, Duration(milliseconds: 244)),
  Level(9, 40, Duration(milliseconds: 172)),
  Level(10, 50, Duration(milliseconds: 124)),
  Level(11, 50, Duration(milliseconds: 75)),
];

class Level {
  final int value;
  final int score;
  final Duration stepDuration;

  const Level(this.value, this.score, this.stepDuration);

  Level? get next {
    if (this == kLevels.last) {
      return null;
    }
    return kLevels[value];
  }
}
