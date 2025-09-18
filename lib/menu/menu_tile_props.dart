import 'dart:math';

import 'package:flutter/material.dart';

class MenuTileProps {
  final GlobalKey key = GlobalKey();
  final Point<int> index;

  final ValueNotifier<Color> color = ValueNotifier(Colors.transparent);

  MenuTileProps({required this.index});
}
