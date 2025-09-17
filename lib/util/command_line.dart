import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/util/fast_key_focus_scope.dart';

class Command {
  final String name;
  final VoidCallback action;

  Command(this.name, this.action);
}

class CommandLineController {
  final List<Command> commands;
  FastKeyEventCallback? _callback;

  CommandLineController(this.commands);

  KeyEventResult onKeyEvent(FastKeyEvent event) {
    return _callback != null ? _callback!(event) : KeyEventResult.ignored;
  }
}

class CommandLine extends StatefulWidget {
  final CommandLineController controller;

  const CommandLine({Key? key, required this.controller}) : super(key: key);

  @override
  State<CommandLine> createState() => _CommandLineState();
}

class _CommandLineState extends State<CommandLine> {
  int _focusedCommandIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller._callback = _onKeyEvent;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _commands.map(
        (e) {
          final isFocused = _commands[_focusedCommandIndex] == e;
          final name = e.name;
          return Text(
            isFocused ? '[$name]' : ' $name ',
            style: TextStyle(
              fontSize: 18,
              color: isFocused ? skGreen : skWhite,
            ),
          );
        },
      ).toList(),
    );
  }

  KeyEventResult _onKeyEvent(FastKeyEvent event) {
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
        if (mounted) {
          setState(() {});
        }
        return KeyEventResult.handled;
      }
    }

    if (event.type != FastKeyEventType.down) {
      return KeyEventResult.ignored;
    }

    // FIXME capture input and find correct command, focus...

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _commands[_focusedCommandIndex].action();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  List<Command> get _commands => widget.controller.commands;
}
