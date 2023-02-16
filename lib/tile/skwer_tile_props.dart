import 'package:flutter/widgets.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_state.dart';

class SkwerTileProps {
  final GlobalKey key = GlobalKey();
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<SkwerTileState> state = ValueNotifier(SkwerTileState());
  final SkwerTileIndex index;
  final ValueNotifier<int> pressCounter = ValueNotifier(0);
  final ValueNotifier<bool> isFocused = ValueNotifier(false);
  final ValueNotifier<bool> isHighlighted = ValueNotifier(false);

  SkwerTileProps({required this.index});
}
