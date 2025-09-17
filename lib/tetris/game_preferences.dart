import 'package:shared_preferences/shared_preferences.dart';
import 'package:skwer/tetris/game_props.dart';

const String tetris = 't';

class GamePrefs {
  Future<int> getHighScore(GameProps props) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$tetris-hs_${props.numTilesX}_${props.numTilesY}') ??
        0;
  }

  void setHighScore(GameProps props, int score) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('$tetris-hs_${props.numTilesX}_${props.numTilesY}', score);
  }
}
