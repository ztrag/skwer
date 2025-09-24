import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skwer/tetris/game_props.dart';

const String tetris = 't';

const _kTileSizes = [
  40.0,
  36.0,
  32.0,
  28.0,
  64.0,
  48.0,
];

class GamePrefs {
  final ValueNotifier<double> _tileSize = ValueNotifier(_kTileSizes[0]);

  int _tileSizeLevel = 0;

  Future<int> getHighScore(GameProps props) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$tetris-hs_${props.numTilesX}_${props.numTilesY}') ??
        0;
  }

  void setHighScore(GameProps props, int score) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('$tetris-hs_${props.numTilesX}_${props.numTilesY}', score);
  }

  ValueListenable<double> get tileSize => _tileSize;

  int get tileSizeLevel => _tileSizeLevel;

  set tileSizeLevel(int value) {
    _tileSizeLevel = value % _kTileSizes.length;
    _tileSize.value = _kTileSizes[_tileSizeLevel];
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setInt('$tetris-ts', value),
    );
  }
}
