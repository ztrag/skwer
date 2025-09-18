import 'dart:math';

import 'package:skwer/colors.dart';
import 'package:skwer/menu/menu_props.dart';

class Menu {
  final MenuProps props = MenuProps();

  void drawWelcome() {
    final anchor = props.bgAnchor;

    for (var i = 0; i < props.numTilesX; i++) {
      for (var j = 0; j < props.numTilesY; j++) {
        props.tiles[Point(i, j)]?.color.value = skRed;
      }
    }

    for (var i = -2; i <= 2; i++) {
      props.tiles[anchor + Point(i, -4)]?.color.value = skYellow;
    }
    for (var i = -3; i <= 3; i++) {
      props.tiles[anchor + Point(i, -3)]?.color.value = skYellow;
    }
    for (var i = -4; i <= 4; i++) {
      props.tiles[anchor + Point(i, -2)]?.color.value = skYellow;
    }
    for (var i = -4; i <= 4; i++) {
      props.tiles[anchor + Point(i, -1)]?.color.value =
          (i == -2 || i == -1 || i == 1 || i == 2) ? skBlack : skYellow;
    }
    for (var i = -4; i <= 4; i++) {
      props.tiles[anchor + Point(i, 0)]?.color.value =
          (i == -2 || i == -1 || i == 1 || i == 2) ? skBlack : skYellow;
    }
    for (var i = -4; i <= 4; i++) {
      props.tiles[anchor + Point(i, 1)]?.color.value =
          (i == 0) ? skBlack : skYellow;
    }
    for (var i = -3; i <= 3; i++) {
      props.tiles[anchor + Point(i, 2)]?.color.value = skYellow;
    }
    for (var i = -2; i <= 2; i++) {
      props.tiles[anchor + Point(i, 3)]?.color.value =
          (i == -1 || i == 0 || i == 1) ? skBlack : skYellow;
    }
    for (var i = -2; i <= 2; i++) {
      props.tiles[anchor + Point(i, 4)]?.color.value =
          (i == -1 || i == 0 || i == 1) ? skBlack : skYellow;
    }
    for (var i = -1; i <= 1; i++) {
      props.tiles[anchor + Point(i, 5)]?.color.value = skYellow;
    }
  }
}
