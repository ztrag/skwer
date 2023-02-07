import 'package:flutter/widgets.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_state.dart';

class SkwerTileProps {
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<SkwerTileState> state = ValueNotifier(SkwerTileState());
  final SkwerTileIndex index;

  SkwerTileProps({required this.index});

  bool get isActive {
    return true;
    // FIXME based on game
    // final index = key.value;
    // return index.x > 3 && index.x <= 8 && index.y > 1 && index.y <= 5;
  }
}
