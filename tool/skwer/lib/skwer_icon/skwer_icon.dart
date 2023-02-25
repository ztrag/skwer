import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:skwer/ascii/ansi_stdout.dart';
import 'package:skwer/process.dart';

const _help = '''
A tool for creating app icons.

1. Provided image is added rounded corners.
2. All macos images are created in place.
3. All android images are created in place.

Available arguments:

 -h               Prints help.

Usage: 

  skwer icon my_icon.png
''';

const _kMacosOut = 'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon';
const _kAndroidOut = 'android/app/src/main/res/mipmap-';

Future<void> skwerIcon(List<String> args) async {
  if (args.length != 1 || args.first == '-h') {
    writeln(_help, TextStyle.help);
    return;
  }
  writeln('Creating icons...', TextStyle.highlighted);

  final macosResult = await _createMacosImages(args.first);
  if (macosResult != 0) {
    return;
  }

  final androidResult = await _createAndroidImages(args.first);
  if (androidResult != 0) {
    return;
  }

  writeln(
    '\nDone, run the following to clear your cache.\n',
    TextStyle.highlighted,
  );
  writeln(
    'sudo rm -rfv /Library/Caches/com.apple.iconservices.store;'
    ' sudo find /private/var/folders/ \\( -name com.apple.dock.iconcache'
    ' -or -name com.apple.iconservices \\) -exec rm -rfv {} \\; ;'
    ' sleep 3;sudo touch /Applications/* ; killall Dock; killall Finder\n',
    TextStyle.highlighted,
  );
}

Future<int> _createMacosImages(String path) async {
  final tempDir = Directory.systemTemp;
  final croppedPath = '${tempDir.path}/cropped.png';
  final cropped = await _createCroppedImage(path, croppedPath, 820);
  if (cropped != 0) {
    return cropped;
  }

  final roundedPath = await _createRoundedCornersImage(croppedPath, tempDir);
  if (roundedPath == null) {
    return 1;
  }

  var paddedPath = '${_kMacosOut}_1024.png';
  final padded = await _createPaddedImage(roundedPath, paddedPath);
  if (padded != 0) {
    return padded;
  }

  for (var size = 16; size < 1024; size *= 2) {
    final result = await _createResizedImage(
      paddedPath,
      '${_kMacosOut}_$size.png',
      size,
    );
    if (result != 0) {
      return result;
    }
  }
  return 0;
}

Future<int> _createAndroidImages(String path) async {
  final tempDir = Directory.systemTemp;
  final croppedPath = '${tempDir.path}/cropped.png';
  final cropped = await _createCroppedImage(path, croppedPath, 820);
  if (cropped != 0) {
    return cropped;
  }

  final paddedPath = '${tempDir.path}_1024.png';
  final padded = await _createPaddedImage(croppedPath, paddedPath);
  if (padded != 0) {
    return padded;
  }

  final name = 'ic_launcher_foreground.png';
  final map = {
    48: 'mdpi',
    72: 'hdpi',
    96: 'xhdpi',
    144: 'xxhdpi',
    192: 'xxxhdpi',
  };
  for (final entry in map.entries) {
    final result = await _createResizedImage(
        paddedPath, '$_kAndroidOut${entry.value}/$name', entry.key);
    if (result != 0) {
      return result;
    }
  }
  return 0;
}

Future<String?> _createRoundedCornersImage(String path, Directory out) async {
  final size = await _getImageSize(path);
  final mask = await runProcess(
    'convert',
    [
      '-size',
      '${size.x}x${size.y}',
      'xc:none',
      '-draw',
      "roundrectangle 0,0,${size.x},${size.y},164,164",
      '${out.path}/mask.png',
    ],
    ProcessStartMode.inheritStdio,
  );
  if (mask != 0) {
    return null;
  }

  final width = 24;
  final roundedOut = '${out.path}/rounded1.png';
  final round = await runProcess(
    'convert',
    [
      path,
      '-matte',
      '${out.path}/mask.png',
      '-compose',
      'DstIn',
      '-composite',
      '-fill',
      'transparent',
      '-stroke',
      '#64be00',
      '-strokewidth',
      '$width',
      '-draw',
      "roundrectangle ${width ~/ 2},${width ~/ 2}"
          " ${820 - width ~/ 2},${820 - width ~/ 2}"
          " 154,154",
      roundedOut,
    ],
  );
  if (round != 0) {
    return null;
  }

  return roundedOut;
}

Future<int> _createPaddedImage(String input, String output) {
  return runProcess('convert', [
    input,
    '-background',
    'none',
    '-gravity',
    'center',
    '-extent',
    '1024x1024',
    output,
  ]);
}

Future<int> _createCroppedImage(String input, String output, int size) {
  return runProcess('convert', [
    input,
    '-gravity',
    'center',
    '-crop',
    '${size}x${size}+0+0',
    '+repage',
    output,
  ]);
}

Future<int> _createResizedImage(String input, String output, int size) {
  return runProcess('convert', [
    input,
    '-resize',
    '${size}x$size',
    output,
  ]);
}

Future<Point<int>> _getImageSize(String path) async {
  final sizeRegex = RegExp(r'(\d+)x(\d+)');
  final identify = await startProcess('identify', [path]);
  Point<int>? size;
  identify.stdout.listen((event) {
    if (size != null) {
      return;
    }

    final split = utf8.decoder.convert(event).split(' ');
    for (final element in split) {
      final matches = sizeRegex.allMatches(element);
      if (matches.isNotEmpty) {
        size = Point(
          int.parse(matches.first.group(1)!),
          int.parse(matches.first.group(2)!),
        );
      }
    }
  });
  await identify.exitCode;
  return size!;
}
