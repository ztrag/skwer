import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skwer/tetris/game_props.dart';

const String tetris = 't';

const _kBoardSizes = [
  10,
  8,
  6,
  4,
  12,
];

class GamePrefs {
  final ValueNotifier<int> _boardSize = ValueNotifier(_kBoardSizes[0]);

  int _boardSizeLevel = 0;

  Future<int> getHighScore(GameProps props) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$tetris-hs_${props.numTilesX}_${props.numTilesY}') ??
        0;
  }

  void setHighScore(GameProps props, int score) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('$tetris-hs_${props.numTilesX}_${props.numTilesY}', score);
  }

  ValueListenable<int> get boardSize => _boardSize;

  int get boardSizeLevel => _boardSizeLevel;

  set boardSizeLevel(int value) {
    _boardSizeLevel = value % _kBoardSizes.length;
    _boardSize.value = _kBoardSizes[_boardSizeLevel];
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setInt('$tetris-bs', value),
    );
  }
}
