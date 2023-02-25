import 'package:console/console.dart';

const kAnsiColorReset = '\x1B[0m';
const kAnsiColorBlack = '\x1B[30m';
const kAnsiColorGrey = '\x1B[30;1m';
const kAnsiColorWhite = '\x1B[37m';
const kAnsiColorWhitePlus = '\x1B[37;1m';
const kAnsiColorRed = '\x1B[31m';
const kAnsiColorRedPlus = '\x1B[31;1m';
const kAnsiColorGreen = '\x1B[32m';
const kAnsiColorGreenPlus = '\x1B[32;1m';
const kAnsiColorYellow = '\x1B[33m';
const kAnsiColorYellowPlus = '\x1B[33;1m';
const kAnsiColorBlue = '\x1B[34m';
const kAnsiColorBluePlus = '\x1B[34;1m';
const kAnsiColorCyan = '\x1B[36m';
const kAnsiColorCyanPlus = '\x1B[36;1m';

enum TextStyle { normal, error, focus, highlighted, process, help }

extension ColorTextStyle on TextStyle {
  String getAnsiColor() {
    switch (this) {
      case TextStyle.normal:
        return kAnsiColorReset;
      case TextStyle.error:
        return kAnsiColorRedPlus;
      case TextStyle.highlighted:
        return kAnsiColorGreen;
      case TextStyle.focus:
        return kAnsiColorGreenPlus;
      case TextStyle.process:
        return kAnsiColorCyan;
      case TextStyle.help:
        return kAnsiColorYellow;
    }
  }
}

void writeln([String o = '', TextStyle textStyle = TextStyle.normal]) {
  if (textStyle != TextStyle.normal) {
    Console.write(textStyle.getAnsiColor());
  }
  Console.write('$o\n');
  if (textStyle != TextStyle.normal) {
    Console.write(kAnsiColorReset);
  }
}

void write([String o = '', TextStyle textStyle = TextStyle.normal]) {
  if (textStyle != TextStyle.normal) {
    Console.write(textStyle.getAnsiColor());
  }
  Console.write(o);
  if (textStyle != TextStyle.normal) {
    Console.write(kAnsiColorReset);
  }
}
