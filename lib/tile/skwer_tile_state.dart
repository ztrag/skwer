import 'package:skwer/game/game_props.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_props.dart';

class SkwerTileState {
  final int skwer;
  final SkwerTileIndex? trigger;
  final bool immediate;

  SkwerTileState._({
    this.skwer = -1,
    this.trigger,
    this.immediate = false,
  });

  factory SkwerTileState() => SkwerTileState._();

  factory SkwerTileState.reset(
    SkwerTileState state,
    int skwer, {
    SkwerTileIndex? trigger,
    bool isLastPressed = false,
    bool immediate = false,
  }) {
    if (state.skwer == skwer && !immediate) {
      return state;
    }
    return SkwerTileState._(
      skwer: skwer,
      trigger: trigger,
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
    );
  }

  bool isFailed(SkwerTileProps props, GameProps gameProps) {
    if (!gameProps.hasPuzzle) {
      return false;
    }

    final skwerDelta = skwer - gameProps.skwer.value;
    return skwerDelta > 0 && skwerDelta % 3 != 0;
  }

  double getBrightness(SkwerTileProps props, GameProps gameProps) {
    if (!gameProps.hasPuzzle) {
      return 1;
    }

    final skwerDelta = skwer - gameProps.skwer.value;
    final hasPuzzleHighlight = skwerDelta < 0;
    final fail = isFailed(props, gameProps);
    if (props.isActive.value) {
      return hasPuzzleHighlight ? 1.4 : (fail ? 1.2 : 1);
    } else {
      return hasPuzzleHighlight ? 5 : (fail ? 5 : 1);
    }
  }
}
