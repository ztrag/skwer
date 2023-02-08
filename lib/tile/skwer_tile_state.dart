import 'package:skwer/game/game_props.dart';
import 'package:skwer/tile/skwer_tile_index.dart';

class SkwerTileState {
  final int skwer;
  final bool hasFocus;
  final bool isLastPressed;
  final bool isActive;
  final bool hasPuzzle;
  final SkwerTileIndex? trigger;

  SkwerTileState._({
    this.skwer = -1,
    this.hasFocus = false,
    this.isLastPressed = false,
    this.isActive = true,
    this.hasPuzzle = false,
    this.trigger,
  });

  factory SkwerTileState() => SkwerTileState._();

  factory SkwerTileState.reset(
    SkwerTileState state,
    int skwer, {
    SkwerTileIndex? trigger,
    bool isActive = true,
    bool hasPuzzle = false,
  }) {
    if (state.skwer == skwer &&
        state.isActive == isActive &&
        state.hasPuzzle == hasPuzzle) {
      return state;
    }
    return SkwerTileState._(
      skwer: skwer,
      trigger: trigger,
      hasFocus: state.hasFocus,
      isActive: isActive,
      hasPuzzle: hasPuzzle,
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
      isActive: state.isActive,
      hasPuzzle: state.hasPuzzle,
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
      isActive: state.isActive,
      hasPuzzle: state.hasPuzzle,
    );
  }

  factory SkwerTileState.onPress(SkwerTileState state) {
    return SkwerTileState._(
      skwer: state.skwer,
      isLastPressed: true,
      hasFocus: state.hasFocus,
      isActive: state.isActive,
      hasPuzzle: state.hasPuzzle,
    );
  }

  double getBrightness(GameProps gameProps) {
    if (!hasPuzzle) {
      return 1;
    }
    final skwerDelta = skwer - gameProps.skwer;
    final hasPuzzleHighlight = skwerDelta < 0;
    final isFailed = skwerDelta > 0 && skwerDelta % 3 != 0;
    if (isActive) {
      return hasPuzzleHighlight ? 1 : (isFailed ? 0.5 : 0.7);
    } else {
      return hasPuzzleHighlight ? 0.9 : (isFailed ? 0.1 : 0.3);
    }
  }
}
