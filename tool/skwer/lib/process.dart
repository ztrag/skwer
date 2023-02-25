import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:skwer/ascii/ansi_stdout.dart';

List<Process> _processStack = <Process>[];

Process? get currentProcess =>
    _processStack.isEmpty ? null : _processStack.last;

Future<Process> startProcess(
  String executable,
  List<String> arguments, [
  ProcessStartMode mode = ProcessStartMode.normal,
]) async {
  writeln(
    'Running `$executable'
    '${arguments.isEmpty ? '' : ' ${arguments.join(' ')}'}`',
    TextStyle.process,
  );
  final process = await Process.start(
    executable,
    arguments,
    mode: mode,
  );
  _processStack.add(process);

  if (mode != ProcessStartMode.detachedWithStdio) {
    process.exitCode.then((value) {
      writeln('Process ended $executable $value $arguments $mode');
      return _processStack.remove(process);
    });
  }
  return process;
}

Future<int> runProcess(
  String executable,
  List<String> arguments, [
  ProcessStartMode mode = ProcessStartMode.normal,
]) async {
  final process = await startProcess(executable, arguments, mode);
  if (mode != ProcessStartMode.detachedWithStdio) {
    return process.exitCode;
  }
  return 1;
}

Future<int> doesProcessOutputLine(
  Process process,
  RegExp pattern, [
  bool printOutput = false,
]) async {
  var hasMatch = false;
  process.stdout.listen((event) {
    if (printOutput) {
      stdout.add(event);
    }

    if (hasMatch) {
      return;
    }
    for (final line in utf8.decoder.convert(event).split('\n')) {
      if (pattern.hasMatch(line)) {
        hasMatch = true;
        return;
      }
    }
  });

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    return exitCode;
  }
  return hasMatch ? 0 : 2;
}
