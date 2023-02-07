import 'package:skwer/tile/skwer_tile_index.dart';

class SkwerTileState {
  final int skwer;
  final bool hasFocus;
  final bool isLastPressed;
  final SkwerTileIndex? trigger;

  SkwerTileState._({
    this.skwer = 0,
    this.hasFocus = false,
    this.isLastPressed = false,
    this.trigger,
  });

  factory SkwerTileState() => SkwerTileState._();

  factory SkwerTileState.reset(
    SkwerTileState state,
    int skwer, {
    SkwerTileIndex? trigger,
  }) {
    return SkwerTileState._(
      skwer: skwer,
      trigger: trigger,
      hasFocus: state.hasFocus,
    );
  }

  factory SkwerTileState.rotate(
    SkwerTileState state,
    SkwerTileIndex trigger,
    int skwerDelta,
  ) {
    return SkwerTileState._(
      skwer: state.skwer + skwerDelta,
      trigger: trigger,
      hasFocus: state.hasFocus,
    );
  }

  factory SkwerTileState.onFocus(
    SkwerTileState state,
    bool hasFocus,
  ) {
    return SkwerTileState._(
      skwer: state.skwer,
      hasFocus: hasFocus,
      trigger: state.trigger,
    );
  }

  factory SkwerTileState.onPress(SkwerTileState state) {
    return SkwerTileState._(
      skwer: state.skwer,
      isLastPressed: true,
      hasFocus: state.hasFocus,
    );
  }
}
