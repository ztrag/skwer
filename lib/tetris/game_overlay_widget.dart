import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/tetris/game_preferences.dart';
import 'package:skwer/tetris/game_props.dart';

class GameOverlayWidget extends StatefulWidget {
  final GameProps gameProps;

  const GameOverlayWidget({
    Key? key,
    required this.gameProps,
  }) : super(key: key);

  @override
  State<GameOverlayWidget> createState() => _GameOverlayWidgetState();
}

class _GameOverlayWidgetState extends State<GameOverlayWidget> {
  final FocusScopeNode _node = FocusScopeNode();
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
    return FocusScope(
      autofocus: true,
      node: _node,
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        if (event.logicalKey == LogicalKeyboardKey.keyR) {
          widget.gameProps.onStart();
          return KeyEventResult.handled;
        }

        if (event.logicalKey == LogicalKeyboardKey.keyQ) {
          widget.gameProps.onExit();
          return KeyEventResult.handled;
        }

        if (widget.gameProps.isPaused.value) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            widget.gameProps.isPaused.value = false;
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },
      child: DefaultTextStyle.merge(
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
                        '-${widget.gameProps.numTilesX}x${widget.gameProps.numTilesY}-',
                        style: TextStyle(
                            fontSize: widget.gameProps.numTilesX > 3 ? 50 : 35,
                            color: skRed),
                      ),
                      Text(
                        '${widget.gameProps.score.value}',
                        style: const TextStyle(fontSize: 60),
                      ),
                      if (!_isNewHighScore)
                        Text(
                          'High Score $_highScore',
                          style: const TextStyle(fontSize: 14),
                        ),
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
      ),
    );
  }
}
