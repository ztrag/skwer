import 'package:flutter/widgets.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_skwer.dart';

class SkwerTileProps {
  final GlobalKey key = GlobalKey();
  final FocusNode focusNode = FocusNode();
  final SkwerTileIndex index;

  final ValueNotifier<SkwerTileSkwer> skwer = ValueNotifier(SkwerTileSkwer());
  final ValueNotifier<int> pressCounter = ValueNotifier(0);
  final ValueNotifier<bool> isFocused = ValueNotifier(false);
  final ValueNotifier<bool> isHighlighted = ValueNotifier(false);
  final ValueNotifier<bool> isActive = ValueNotifier(true);
  final ValueNotifier<Offset?> hoverPosition = ValueNotifier(null);

  SkwerTileProps({required this.index});
}
