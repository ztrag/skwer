import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:skwer/ascii/ansi_stdout.dart';
import 'package:console/console.dart';

class CommandLine {
  final Map<String, FutureOr Function()> _commands;

  List<String> _candidateCommands = <String>[];
  int _focusIndex = 0;
  String _input = '';
  int _commandCount = 0;
  int _inputMoveBytesRead = 0;

  CommandLine(this._commands);

  set focusIndex(int value) {
    _focusIndex = value;
  }

  Future<void> take([int? byte]) async {
    stdin.echoMode = false;
    stdin.lineMode = false;
    Console.hideCursor();
    _input = '';
    _focusIndex = max(min(_focusIndex, _commands.length - 1), 0);
    _candidateCommands = [..._commands.keys];

    if (byte != null && byte != 10) {
      await _handleByte(byte);
    }

    while (true) {
      _printCommandLine();
      final byte = stdin.readByteSync();
      if (await _handleByte(byte)) {
        return;
      }
    }
  }

  Future<void> _printCommandLine() async {
    final color =
        _candidateCommands.isEmpty ? TextStyle.error : TextStyle.focus;
    _eraseCommandLine();
    write('>${_input.isNotEmpty ? ' $_input ->' : ''}', color);
    _printCandidateCommandsWithFocus();
  }

  void _eraseCommandLine() {
    Console.moveToColumn(0);
    Console.eraseLine();
  }

  void _printCandidateCommandsWithFocus() {
    if (_candidateCommands.isEmpty) {
      write(' <null>', TextStyle.error);
      return;
    }

    for (var i = 0; i < _candidateCommands.length; i++) {
      final command = _candidateCommands[i];
      if (i == _focusIndex) {
        write(' [$command]', TextStyle.focus);
      } else {
        write(' $command');
      }
    }
  }

  Future<bool> _handleByte(int byte) async {
    if (await _maybeToggleCommand(byte)) {
      // left/right/up/down/escape
      return false;
    }

    switch (byte) {
      case 10: // enter
        return _runFocusedCommand();
      case 127: // backspace
        if (_input.isNotEmpty) {
          await _setInput(_input.substring(0, _input.length - 1));
        }
        break;
      default:
        final char = String.fromCharCode(byte);
        if (RegExp('[a-z]|-|[0-9]').hasMatch(char)) {
          await _setInput('$_input$char');
        }
    }
    return false;
  }

  Future<void> _setInput(String value) async {
    _input = value;

    _candidateCommands = _getCandidateCommands(_input);
    if (_candidateCommands.isNotEmpty) {
      _focusIndex %= _candidateCommands.length;
    } else {
      _focusIndex = 0;
    }
  }

  List<String> _getCandidateCommands(String input) {
    final candidates = <String>[];
    for (final command in _commands.keys) {
      if (_isCandidate(input, command)) {
        candidates.add(command);
      }
    }
    return candidates;
  }

  bool _isCandidate(String input, String command) {
    final splitInput = input.split('').join('.*');
    final inputRegExp = RegExp('^$splitInput');
    return inputRegExp.hasMatch(command);
  }

  Future<bool> _maybeToggleCommand(int byte) async {
    if (_candidateCommands.isEmpty) {
      return false;
    }
    // TODO breaks stdin for flutter run (debug)
    if (byte == 27) {
      // escape and first part of move arrows
      _inputMoveBytesRead = 1;
      return true;
    } else if (byte == 91 && _inputMoveBytesRead == 1) {
      ++_inputMoveBytesRead;
      return true;
    } else if ((byte >= 65 && byte <= 68) && _inputMoveBytesRead == 2) {
      final dir = (byte == 68 || byte == 65) ? -1 : 1;
      _focusIndex += dir;
      _focusIndex %= _candidateCommands.length;
      return true;
    }
    return false;
  }

  Future<bool> _runFocusedCommand() async {
    _eraseCommandLine();

    if (_candidateCommands.isEmpty ||
        _focusIndex < 0 ||
        _focusIndex >= _candidateCommands.length) {
      writeln('> $_input -> <null>', TextStyle.error);
      _setInput('');
      return false;
    }

    final command = _candidateCommands[_focusIndex];
    final labeledCommand = '$command(${++_commandCount})';

    writeln('> $labeledCommand', TextStyle.highlighted);
    writeln();
    Console.moveCursor(row: Console.rows);
    await _commands[_candidateCommands[_focusIndex]]!();
    return true;
  }
}

Future<int> confirmCommand({
  String no = 'no',
  String yes = 'yes',
  required Future<int> Function() command,
  bool inConsole = false,
}) async {
  writeln('Are you sure?');
  final completer = Completer<int>();
  final commandLine = CommandLine(<String, Function()>{
    no: () {
      if (!inConsole) {
        writeln('Bye-bye.', TextStyle.error);
      }
      completer.complete(0);
    },
    yes: () async {
      completer.complete(await command());
    },
  });

  while (true) {
    await commandLine.take();
    if (completer.isCompleted) {
      break;
    }
  }
  return completer.future;
}
