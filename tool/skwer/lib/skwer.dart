import 'package:skwer/ascii/ansi_stdout.dart';
import 'package:skwer/skwer_build_tool/skwer_build_tool.dart';
import 'package:skwer/skwer_icon/skwer_icon.dart';

const _help = '''
A tool for developing skwer

Available commands:

 help [-h]    --  Print help.
 build-tool  ---  Build skwer tool.
 icon   -- -- --  Create app icons.
 

Usage: skwer <command> [arguments]
''';

void main(List<String> args) async {
  if (args.isEmpty) {
    _skwerHelp();
    return;
  }

  _runSkwerCommand(args);
}

void _runSkwerCommand(List<String> args) {
  final command = args.first;
  final commandArgs = args.sublist(1);

  switch (command) {
    case '-h':
      _skwerHelp();
      return;
    case 'build-tool':
      skwerBuildTool();
      return;
    case 'icon':
      skwerIcon(commandArgs);
      return;
    default:
      writeln('Unknown command [$command]\n', TextStyle.error);
      _skwerHelp();
      return;
  }
}

void _skwerHelp() {
  writeln(_help, TextStyle.help);
}
