import 'dart:math';

import 'package:flutter/services.dart';
import 'package:skwer/util/fast_key_focus.dart';
import 'package:skwer/util/touch_arrows.dart';

class MoveArrows {
  static final Map<LogicalKeyboardKey, Point<int>> _arrowPoints = {
    LogicalKeyboardKey.arrowLeft: const Point(-1, 0),
    LogicalKeyboardKey.arrowRight: const Point(1, 0),
    LogicalKeyboardKey.arrowUp: const Point(0, -1),
    LogicalKeyboardKey.arrowDown: const Point(0, 1),
  };

  static int getHorizontalDirection(FastKeyFocusController focusScopeController,
      TouchArrowsController touchArrowsController) {
    final left = _merge(
      focusScopeController.getKeyDownTime(LogicalKeyboardKey.arrowLeft),
      touchArrowsController.getLastDirectionTouchTime(Direction.left),
    );
    final right = _merge(
      focusScopeController.getKeyDownTime(LogicalKeyboardKey.arrowRight),
      touchArrowsController.getLastDirectionTouchTime(Direction.right),
    );

    if (left != null && (right == null || left > right)) {
      return -1;
    }
    if (right != null && (left == null || right > left)) {
      return 1;
    }
    return 0;
  }

  static Duration? _merge(Duration? k, Duration? t) {
    return k != null && t != null ? (k > t ? k : t) : (k ?? t);
  }

  static Point<int>? getDir(FastKeyEvent event) {
    if (event.type == FastKeyEventType.up) {
      return null;
    }

    return _arrowPoints[event.logicalKey];
  }
}
