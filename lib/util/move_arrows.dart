import 'package:flutter/services.dart';
import 'package:skwer/util/fast_key_focus_scope.dart';

class MoveArrows {
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
}
