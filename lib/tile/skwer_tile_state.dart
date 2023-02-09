import 'package:skwer/game/game_props.dart';
import 'package:skwer/tile/skwer_tile_index.dart';

class SkwerTileState {
  final int skwer;
  final bool hasFocus;
  final bool isLastPressed;
  final bool isActive;
  final bool hasPuzzle;
  final bool isSolved;
  final bool isHighlighted;
  final SkwerTileIndex? trigger;

  SkwerTileState._({
    this.skwer = -1,
    this.hasFocus = false,
    this.isLastPressed = false,
    this.isActive = true,
    this.hasPuzzle = false,
    this.isSolved = false,
    this.isHighlighted = false,
    this.trigger,
  });

  factory SkwerTileState() => SkwerTileState._();

  factory SkwerTileState.reset(
    SkwerTileState state,
    int skwer, {
    SkwerTileIndex? trigger,
    bool? isActive,
    bool hasPuzzle = false,
    bool isSolved = false,
  }) {
    if (state.skwer == skwer &&
        state.isActive == isActive &&
        state.isSolved == isSolved &&
        state.hasPuzzle == hasPuzzle) {
      return state;
    }
    return SkwerTileState._(
      skwer: skwer,
      trigger: trigger,
      hasFocus: state.hasFocus,
      isActive: isActive ?? state.isActive,
      hasPuzzle: hasPuzzle,
      isSolved: isSolved,
      isHighlighted: false,
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
      isHighlighted: state.isHighlighted,
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

  factory SkwerTileState.onHighlight(
    SkwerTileState state,
    bool isHighlighted,
  ) {
    return SkwerTileState._(
      skwer: state.skwer,
      hasFocus: state.hasFocus,
      trigger: state.trigger,
      isActive: state.isActive,
      hasPuzzle: state.hasPuzzle,
      isSolved: state.isSolved,
      isHighlighted: isHighlighted,
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

  bool isFailed(GameProps gameProps) {
    if (!hasPuzzle) {
      return false;
    }

    final skwerDelta = skwer - gameProps.skwer;
    return skwerDelta > 0 && skwerDelta % 3 != 0;
  }

  double getBrightness(GameProps gameProps) {
    if (!hasPuzzle) {
      return 1;
    }

    if (hasFocus) {
      return 1.4;
    }

    if (isSolved) {
      return isActive ? 0.9 : 0.5;
    }

    final skwerDelta = skwer - gameProps.skwer;
    final hasPuzzleHighlight = skwerDelta < 0;
    final fail = isFailed(gameProps);
    if (isActive) {
      return hasPuzzleHighlight ? 1 : (fail ? 0.9 : 0.7);
    } else {
      return hasPuzzleHighlight ? 0.8 : (fail ? 0.7 : 0.2);
    }
  }
}
