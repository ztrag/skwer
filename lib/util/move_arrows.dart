import 'dart:math';

import 'package:flutter/services.dart';
import 'package:skwer/util/fast_key_focus_scope.dart';

class MoveArrows {
  static final Map<LogicalKeyboardKey, Point<int>> _arrowPoints = {
    LogicalKeyboardKey.arrowLeft: const Point(-1, 0),
    LogicalKeyboardKey.arrowRight: const Point(1, 0),
    LogicalKeyboardKey.arrowUp: const Point(0, -1),
    LogicalKeyboardKey.arrowDown: const Point(0, 1),
  };

  static int getHorizontalDirection(
      FastKeyFocusScopeController focusScopeController) {
    final left =
        focusScopeController.getKeyDownTime(LogicalKeyboardKey.arrowLeft);
    final right =
        focusScopeController.getKeyDownTime(LogicalKeyboardKey.arrowRight);

    if (left != null && (right == null || left > right)) {
      return -1;
    }
    if (right != null && (left == null || right > left)) {
      return 1;
    }
    return 0;
  }

  static Point<int>? getDir(FastKeyEvent event) {
    if (event.type == FastKeyEventType.up) {
      return null;
    }

    return _arrowPoints[event.logicalKey];
  }
}
