import 'dart:math';
import 'dart:ui';

import 'package:skwer/colors.dart';

enum Tetramino {
  i(skYellow),
  o(skRed),
  t(skPurple),
  j(skOrange),
  l(skCyan),
  s(skBlue),
  z(skGreen);

  final Color color;

  const Tetramino(this.color);

  List<Point<int>> points(int rotation) {
    switch (this) {
      case Tetramino.i:
        return _iPoints[rotation % 2];
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

  Point<int> spawnOffset() {
    switch (this) {
      case Tetramino.i:
      case Tetramino.t:
      case Tetramino.l:
        return const Point(2, 1);
      case Tetramino.j:
        return const Point(1, 1);
      case Tetramino.o:
      case Tetramino.s:
        return const Point(1, 0);
      case Tetramino.z:
        return const Point(2, 0);
    }
  }

  List<Point<int>> wallKickTests(int rotation) {
    switch (this) {
      case Tetramino.i:
        return _iWallKickTests[rotation % 2];
      case Tetramino.o:
        return [];
      case Tetramino.t:
        return _tWallKickTests[rotation];
      case Tetramino.j:
        return _jWallKickTests[rotation];
      case Tetramino.l:
        return _lWallKickTests[rotation];
      case Tetramino.s:
        return _sWallKickTests[rotation % 2];
      case Tetramino.z:
        return _zWallKickTests[rotation % 2];
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
];

const List<Point<int>> _oPoints = [
  Point(0, 0),
  Point(1, 0),
  Point(0, 1),
  Point(1, 1),
];

const List<List<Point<int>>> _tPoints = [
  [
    Point(0, 1),
    Point(1, 1),
    Point(2, 1),
    Point(1, 2),
  ],
  [
    Point(1, 0),
    Point(1, 1),
    Point(1, 2),
    Point(2, 1),
  ],
  [
    Point(1, 0),
    Point(0, 1),
    Point(1, 1),
    Point(2, 1),
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

const List<List<Point<int>>> _iWallKickTests = [
  [
    Point(0, -1),
    Point(0, -2),
    Point(0, 1),
  ],
  [
    Point(1, 0),
    Point(-1, 0),
    Point(2, 0),
  ],
];

const List<List<Point<int>>> _tWallKickTests = [
  [
    Point(0, 1),
    Point(-1, 1),
  ],
  [
    Point(1, 0),
  ],
  [
    Point(0, -1),
    Point(1, -1),
  ],
  [
    Point(-1, 0),
    Point(0, -1),
  ],
];

const List<List<Point<int>>> _jWallKickTests = [
  [
    Point(0, 1),
    Point(-1, 0),
    Point(1, 0),
  ],
  [
    Point(1, 0),
    Point(0, -1),
    Point(1, -1),
  ],
  [
    Point(0, -1),
    Point(-1, -1),
  ],
  [
    Point(-1, 0),
    Point(1, 0),
  ],
];

const List<List<Point<int>>> _lWallKickTests = [
  [
    Point(0, 1),
    Point(-1, 0),
    Point(-1, 1),
  ],
  [
    Point(1, 0),
    Point(0, 1),
    Point(-1, 0),
  ],
  [
    Point(0, -1),
    Point(1, 0),
    Point(1, -1),
  ],
  [
    Point(-1, 0),
    Point(0, -1),
    Point(0, -2),
  ],
];

const List<List<Point<int>>> _sWallKickTests = [
  [
    Point(-1, 0),
    Point(0, -1),
    Point(-1, -1),
  ],
  [
    Point(1, 0),
    Point(0, 1),
    Point(1, 1),
  ],
];

const List<List<Point<int>>> _zWallKickTests = [
  [
    Point(1, 0),
    Point(0, -1),
    Point(1, -1),
  ],
  [
    Point(-1, 0),
    Point(0, 1),
    Point(-1, 1),
  ],
];
