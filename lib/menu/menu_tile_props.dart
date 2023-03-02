import 'dart:math';

import 'package:flutter/material.dart';

class MenuTileProps {
  final GlobalKey key = GlobalKey();
  final FocusNode focusNode = FocusNode();
  final Point<int> index;

  final ValueNotifier<Color> color = ValueNotifier(Colors.transparent);
  final ValueNotifier<bool> isFocused = ValueNotifier(false);
  final ValueNotifier<Offset?> hoverPosition = ValueNotifier(null);

  MenuTileProps({required this.index});
}
