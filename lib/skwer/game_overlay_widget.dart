import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/skwer/game_props.dart';
import 'package:skwer/skwer/help.dart';
import 'package:skwer/util/command_line.dart';
import 'package:skwer/util/fast_key_focus.dart';

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
      CommandLineController([
    Command('help', () => _isShowingHelp.value = true),
    Command('quit', widget.gameProps.onExit),
  ]);
  final ValueNotifier<bool> _isShowingHelp = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    widget.gameProps.onOverlayKeyEvent = _onKeyEvent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: skBlack.withAlpha(180),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder(
                  valueListenable: _isShowingHelp,
                  builder: (_, isHelp, ___) => Text(
                    isHelp ? 'help' : 'skwer',
                    style: const TextStyle(fontSize: 40, color: skRed),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _isShowingHelp,
                  builder: (_, isHelp, ___) => isHelp
                      ? const Help()
                      : CommandLine(controller: commandLineController),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  KeyEventResult _onKeyEvent(FastKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isShowingHelp.value) {
        _isShowingHelp.value = false;
      } else {
        widget.gameProps.isShowingOverlay.value = false;
      }
      return KeyEventResult.handled;
    }

    return commandLineController.onKeyEvent(event);
  }
}
