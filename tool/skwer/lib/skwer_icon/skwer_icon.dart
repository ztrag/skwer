import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:skwer/ascii/ansi_stdout.dart';
import 'package:skwer/process.dart';

const _help = '''
A tool for creating app icons.

1. Provided image is added rounded corners.
2. All macos images are created in place.
3. Windows ico is created in place.
4. All android images are created in place.

Available arguments:

 -h               Prints help.

Usage: 

  skwer icon app_icon.png
''';

const _kMacosOut = 'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon';
const _kWindowsOut = 'windows/runner/resources/app_icon.ico';
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

  final windowsResult = await _createWindowsImages(args.first);
  if (windowsResult != 0) {
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

  final roundedPath = '${tempDir.path}/rounded.png';
  final rounded =
      await _createRoundedCornersImage(croppedPath, roundedPath, 164, 152, 24);
  if (rounded != 0) {
    return rounded;
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

Future<int> _createWindowsImages(String path) async {
  final tempDir = Directory.systemTemp;
  final croppedPath = '${tempDir.path}/cropped.png';
  final cropped = await _createCroppedImage(path, croppedPath, 820);
  if (cropped != 0) {
    return cropped;
  }

  final roundedPath = '${tempDir.path}/rounded.png';
  final rounded =
      await _createRoundedCornersImage(croppedPath, roundedPath, 164, 152, 24);
  if (rounded != 0) {
    return rounded;
  }

  final resizedPaths = <String>[];
  for (var size = 16; size <= 256; size *= 2) {
    resizedPaths.add('${tempDir.path}/resized_$size.png');
    final result = await _createResizedImage(
      roundedPath,
      resizedPaths.last,
      size,
    );
    if (result != 0) {
      return result;
    }
  }

  final ico = await _createIco(resizedPaths, _kWindowsOut);
  return ico;
}

Future<int> _createAndroidImages(String path) async {
  final tempDir = Directory.systemTemp;
  final croppedPath = '${tempDir.path}/cropped.png';
  final cropped = await _createCroppedImage(path, croppedPath, 820);
  if (cropped != 0) {
    return cropped;
  }

  final resizedPath = '${tempDir.path}/resized.png';
  final resized = await _createResizedImage(croppedPath, resizedPath, 690);
  if (resized != 0) {
    return resized;
  }

  final roundedCornersPath = '${tempDir.path}/rounded.png';
  final roundedCorners = await _createRoundedCornersImage(
      resizedPath, roundedCornersPath, 100, 90, 21);
  if (roundedCorners != 0) {
    return roundedCorners;
  }

  final paddedRoundedCornersPath = '${tempDir.path}_1024.png';
  final paddedRoundedCorners =
      await _createPaddedImage(roundedCornersPath, paddedRoundedCornersPath);
  if (paddedRoundedCorners != 0) {
    return paddedRoundedCorners;
  }

  final icLauncherForeground = await _createAndroidImageSet(
      paddedRoundedCornersPath, 'ic_launcher_foreground.png');
  if (icLauncherForeground != 0) {
    return icLauncherForeground;
  }

  final circledPath = '${tempDir.path}/circled.png';
  final circled = await _createCircledImage(resizedPath, circledPath, 20);
  if (circled != 0) {
    return circled;
  }

  final paddedCircledPath = '${tempDir.path}_c_1024.png';
  final paddedCircled =
      await _createPaddedImage(circledPath, paddedCircledPath);
  if (paddedCircled != 0) {
    return paddedCircled;
  }

  final icLauncherForegroundRound = await _createAndroidImageSet(
      paddedCircledPath, 'ic_launcher_foreground_round.png');
  if (icLauncherForegroundRound != 0) {
    return icLauncherForegroundRound;
  }

  return 0;
}

Future<int> _createAndroidImageSet(String path, String name) async {
  final androidSizeMap = {
    48: 'mdpi',
    72: 'hdpi',
    96: 'xhdpi',
    144: 'xxhdpi',
    192: 'xxxhdpi',
  };
  for (final entry in androidSizeMap.entries) {
    final result = await _createResizedImage(
        path, '$_kAndroidOut${entry.value}/$name', entry.key);
    if (result != 0) {
      return result;
    }
  }
  return 0;
}

Future<int> _createCircledImage(String input, String output, int width) async {
  final size = await _getImageSize(input);
  final maskPath = '${Directory.systemTemp.path}/mask.png';
  final mask = await runProcess(
    'magick',
    [
      '-size',
      '${size.x}x${size.y}',
      'xc:none',
      '-draw',
      "circle ${size.x ~/ 2},${size.y ~/ 2} 0,${size.x ~/ 2}",
      maskPath,
    ],
    ProcessStartMode.inheritStdio,
  );
  if (mask != 0) {
    return mask;
  }

  return runProcess(
    'magick',
    [
      input,
      '-fill',
      'transparent',
      '-stroke',
      '#64be00',
      '-strokewidth',
      '$width',
      '-draw',
      "circle ${size.x ~/ 2},${size.y ~/ 2}"
          " ${width ~/ 2 + 0.5},${size.x ~/ 2}",
      '-matte',
      maskPath,
      '-compose',
      'DstIn',
      '-composite',
      output,
    ],
  );
}

Future<int> _createRoundedCornersImage(String input, String output,
    int borderRadius1, int borderRadius2, int width) async {
  final size = await _getImageSize(input);
  final maskPath = '${Directory.systemTemp.path}/mask.png';
  final mask = await runProcess(
    'magick',
    [
      '-size',
      '${size.x}x${size.y}',
      'xc:none',
      '-draw',
      "roundrectangle 0,0,${size.x},${size.y},$borderRadius1,$borderRadius1",
      maskPath,
    ],
    ProcessStartMode.inheritStdio,
  );
  if (mask != 0) {
    return mask;
  }

  return runProcess(
    'magick',
    [
      input,
      '-matte',
      maskPath,
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
          " ${size.x - width ~/ 2},${size.x - width ~/ 2}"
          " $borderRadius2,$borderRadius2",
      output,
    ],
  );
}

Future<int> _createPaddedImage(
  String input,
  String output, [
  int outSize = 1024,
]) {
  return runProcess('magick', [
    input,
    '-background',
    'none',
    '-gravity',
    'center',
    '-extent',
    '${outSize}x$outSize',
    output,
  ]);
}

Future<int> _createCroppedImage(String input, String output, int size) {
  return runProcess('magick', [
    input,
    '-gravity',
    'center',
    '-crop',
    '${size}x$size+0+0',
    '+repage',
    output,
  ]);
}

Future<int> _createResizedImage(String input, String output, int size) {
  return runProcess('magick', [
    input,
    '-resize',
    '${size}x$size',
    output,
  ]);
}

Future<int> _createIco(List<String> input, String output) {
  return runProcess('magick', [...input, output]);
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
