import 'dart:math';

enum Tetramino {
  i,
  o,
  t,
  j,
  l,
  s,
  z;

  List<Point<int>> points(int rotation) {
    switch (this) {
      case Tetramino.i:
        return _iPoints[rotation];
      case Tetramino.o:
        return _oPoints;
      case Tetramino.t:
        return _tPoints[rotation];
      case Tetramino.j:
        return _jPoints[rotation];
      case Tetramino.l:
        return _lPoints[rotation];
      case Tetramino.s:
        return _sPoints[rotation % 2];
      case Tetramino.z:
        return _zPoints[rotation % 2];
    }
  }
}

const List<List<Point<int>>> _iPoints = [
  [
    Point(0, 1),
    Point(1, 1),
    Point(2, 1),
    Point(3, 1),
  ],
  [
    Point(2, 0),
    Point(2, 1),
    Point(2, 2),
    Point(2, 3),
  ],
  [
    Point(0, 2),
    Point(1, 2),
    Point(2, 2),
    Point(3, 2),
  ],
  [
    Point(1, 0),
    Point(1, 1),
    Point(1, 2),
    Point(1, 3),
  ],
];

const List<Point<int>> _oPoints = [
  Point(1, 0),
  Point(2, 0),
  Point(1, 1),
  Point(2, 1),
];

const List<List<Point<int>>> _tPoints = [
  [
    Point(1, 0),
    Point(0, 1),
    Point(1, 1),
    Point(2, 1),
  ],
  [
    Point(1, 0),
    Point(1, 1),
    Point(1, 2),
    Point(2, 1),
  ],
  [
    Point(0, 1),
    Point(1, 1),
    Point(2, 1),
    Point(1, 2),
  ],
  [
    Point(0, 1),
    Point(1, 0),
    Point(1, 1),
    Point(1, 2),
  ],
];

const List<List<Point<int>>> _jPoints = [
  [
    Point(0, 1),
    Point(1, 1),
    Point(2, 1),
    Point(2, 2),
  ],
  [
    Point(1, 0),
    Point(1, 1),
    Point(1, 2),
    Point(2, 0),
  ],
  [
    Point(0, 0),
    Point(0, 1),
    Point(1, 1),
    Point(2, 1),
  ],
  [
    Point(0, 2),
    Point(1, 0),
    Point(1, 1),
    Point(1, 2),
  ],
];

const List<List<Point<int>>> _lPoints = [
  [
    Point(0, 1),
    Point(1, 1),
    Point(2, 1),
    Point(0, 2),
  ],
  [
    Point(1, 0),
    Point(1, 1),
    Point(1, 2),
    Point(2, 2),
  ],
  [
    Point(0, 1),
    Point(1, 1),
    Point(2, 1),
    Point(2, 0),
  ],
  [
    Point(0, 0),
    Point(1, 0),
    Point(1, 1),
    Point(1, 2),
  ],
];

const List<List<Point<int>>> _sPoints = [
  [
    Point(0, 1),
    Point(1, 0),
    Point(1, 1),
    Point(2, 0),
  ],
  [
    Point(1, 0),
    Point(1, 1),
    Point(2, 1),
    Point(2, 2),
  ],
];

const List<List<Point<int>>> _zPoints = [
  [
    Point(0, 0),
    Point(1, 0),
    Point(1, 1),
    Point(2, 1),
  ],
  [
    Point(0, 1),
    Point(0, 2),
    Point(1, 0),
    Point(1, 1),
  ],
];
