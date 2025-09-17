import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/tetris/game_preferences.dart';
import 'package:skwer/tetris/game_props.dart';
import 'package:skwer/util/fast_key_focus_scope.dart';

class _Command {
  final String name;
  final VoidCallback action;

  _Command(this.name, this.action);
}

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
  late final List<_Command> _commands = [
    _Command('restart', widget.gameProps.onStart),
    _Command('quit', widget.gameProps.onExit),
  ];
  int _focusedCommandIndex = 0;

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
                    ..._commands.map(
                      (e) {
                        final isFocused = _commands[_focusedCommandIndex] == e;
                        final name = e.name;
                        return Text(
                          isFocused ? '[$name]' : name,
                          style: TextStyle(
                            fontSize: 18,
                            color: isFocused ? skGreen : skWhite,
                          ),
                        );
                      },
                    ),
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

    if (event.type != FastKeyEventType.up) {
      final isFocusLeft = event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowUp;
      final isFocusRight = event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.arrowDown;
      if (isFocusLeft || isFocusRight) {
        if (isFocusLeft) {
          _focusedCommandIndex =
              (_focusedCommandIndex + _commands.length - 1) % _commands.length;
        } else {
          _focusedCommandIndex = (_focusedCommandIndex + 1) % _commands.length;
        }
        setState(() {});
        return KeyEventResult.handled;
      }
    }

    if (event.type != FastKeyEventType.down) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      setState(() {
        _focusedCommandIndex = _commands.indexWhere((e) => e.name == 'restart');
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyQ) {
      setState(() {
        _focusedCommandIndex = _commands.indexWhere((e) => e.name == 'quit');
      });
      return KeyEventResult.handled;
    }

    if (widget.gameProps.isPaused.value) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.gameProps.isPaused.value = false;
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _commands[_focusedCommandIndex].action();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
