import 'package:skwer/ascii/ansi_stdout.dart';
import 'package:skwer/process.dart';

Future<void> skwerBuildTool() async {
  writeln('Building skwer...', TextStyle.highlighted);
  await runProcess(
    'dart',
    ['pub', 'global', 'activate', '--source', 'path', './tool/skwer'],
  );
}
