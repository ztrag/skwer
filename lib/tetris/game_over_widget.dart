import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/tetris/game_preferences.dart';
import 'package:skwer/tetris/game_props.dart';

class GameOverWidget extends StatefulWidget {
  final GameProps gameProps;

  const GameOverWidget({Key? key, required this.gameProps}) : super(key: key);

  @override
  State<GameOverWidget> createState() => _GameOverWidgetState();
}

class _GameOverWidgetState extends State<GameOverWidget> {
  int? _highScore;
  bool _isNewHighScore = false;

  @override
  void initState() {
    super.initState();
    _updateHighScore();
  }

  void _updateHighScore() async {
    _highScore = null;
    _highScore = await GamePrefs().getHighScore(widget.gameProps);
    _isNewHighScore = widget.gameProps.score.value > (_highScore ?? -1);

    if (_isNewHighScore) {
      _highScore = widget.gameProps.score.value;
      GamePrefs().setHighScore(widget.gameProps, _highScore!);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_highScore == null) {
      return const SizedBox.shrink();
    }
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 20, color: skWhite),
      child: Container(
        color: skBlack.withAlpha(150),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      '(${widget.gameProps.numTilesX},${widget.gameProps.numTilesY})',
                      style: TextStyle(
                          fontSize: widget.gameProps.numTilesX > 3 ? 50 : 35,
                          color: skRed),
                    ),
                    Text(
                      '${widget.gameProps.score.value}',
                      style: const TextStyle(fontSize: 60),
                    ),
                    Text(_isNewHighScore
                        ? 'New High Score'
                        : 'High Score $_highScore'),
                    const SizedBox(height: 40),
                    const Text('r - Restart', style: TextStyle(fontSize: 18)),
                    const Text('q - Quit', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
