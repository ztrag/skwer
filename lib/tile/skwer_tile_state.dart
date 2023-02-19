import 'package:skwer/game/game_props.dart';
import 'package:skwer/tile/skwer_tile_index.dart';

class SkwerTileState {
  final int skwer;
  final bool isActive;
  final bool hasPuzzle;
  final bool isSolved;
  final SkwerTileIndex? trigger;
  final bool immediate;

  SkwerTileState._({
    this.skwer = -1,
    this.isActive = true,
    this.hasPuzzle = false,
    this.isSolved = false,
    this.trigger,
    this.immediate = false,
  });

  factory SkwerTileState() => SkwerTileState._();

  factory SkwerTileState.reset(
    SkwerTileState state,
    int skwer, {
    SkwerTileIndex? trigger,
    bool? isActive,
    bool hasPuzzle = false,
    bool isSolved = false,
    bool isLastPressed = false,
    bool immediate = false,
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
      isActive: isActive ?? state.isActive,
      hasPuzzle: hasPuzzle,
      isSolved: isSolved,
      immediate: immediate,
    );
  }

  factory SkwerTileState.rotate(
    SkwerTileState state,
    SkwerTileIndex trigger,
    int skwerDelta,
  ) {
    return SkwerTileState._(
      skwer: state.skwer + skwerDelta,
      trigger: skwerDelta > 0 ? trigger : null,
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

    if (isSolved) {
      return isActive ? 0.9 : 0.5;
    }

    final skwerDelta = skwer - gameProps.skwer;
    final hasPuzzleHighlight = skwerDelta < 0;
    final fail = isFailed(gameProps);
    if (isActive) {
      return hasPuzzleHighlight ? 1 : (fail ? 0.9 : 0.7);
    } else {
      return hasPuzzleHighlight ? 0.7 : (fail ? 0.7 : 0.15);
    }
  }
}
