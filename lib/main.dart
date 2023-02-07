import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/game.dart';

void main() {
  runApp(const MaterialApp(home: Game()));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
}
