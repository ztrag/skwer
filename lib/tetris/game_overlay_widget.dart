import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/tetris/game_preferences.dart';
import 'package:skwer/tetris/game_props.dart';
import 'package:skwer/util/command_line.dart';
import 'package:skwer/util/fast_key_focus_scope.dart';

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
  late final CommandLineController commandLineController =
      CommandLineController(
    [
      Command('restart', widget.gameProps.onStart),
      Command('quit', widget.gameProps.onExit),
    ],
  );

  int? _highScore;
  bool _isNewHighScore = false;
  bool _ignoreInput = true;

  @override
  void initState() {
    super.initState();
    _updateHighScore();
    widget.gameProps.onOverlayKeyEvent = _onKeyEvent;
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
                      '-${widget.gameProps.numTilesX}x${widget.gameProps.numTilesY}-',
                      style: TextStyle(
                          fontSize: widget.gameProps.numTilesX > 3 ? 50 : 35,
                          color: skRed),
                    ),
                    if (!_isNewHighScore)
                      Text(
                        'High Score $_highScore',
                        style: const TextStyle(fontSize: 14),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      '${widget.gameProps.score.value}',
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 20),
                    CommandLine(controller: commandLineController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  KeyEventResult _onKeyEvent(FastKeyEvent event) {
    if (event.type == FastKeyEventType.down) {
      _ignoreInput = false;
    }

    if (_ignoreInput) {
      return KeyEventResult.ignored;
    }

    if (widget.gameProps.isPaused.value) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.gameProps.isPaused.value = false;
        return KeyEventResult.handled;
      }
    }

    return commandLineController.onKeyEvent(event);
  }
}
