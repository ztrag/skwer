import 'package:skwer/skwer/game_props.dart';
import 'package:skwer/tile/skwer_tile_index.dart';
import 'package:skwer/tile/skwer_tile_props.dart';

class SkwerTileSkwer {
  final int skwer;
  final SkwerTileIndex? trigger;
  final DateTime time;
  final bool animateColor;
  final bool animateWave;

  SkwerTileSkwer({
    this.skwer = 0,
    this.trigger,
    this.animateColor = false,
    this.animateWave = false,
  }) : time = DateTime.now();

  SkwerTileSkwer rotate(
    SkwerTileIndex trigger,
    int delta,
    bool animateWave,
  ) {
    return SkwerTileSkwer(
      skwer: skwer + delta,
      trigger: trigger,
      animateColor: true,
      animateWave: animateWave,
    );
  }

  bool isFailed(SkwerTileProps props, GameProps gameProps) {
    if (!gameProps.hasPuzzle) {
      return false;
    }

    final skwerDelta = skwer - gameProps.skwer.value;
    return skwerDelta > 0 && skwerDelta % 3 != 0;
  }
}
