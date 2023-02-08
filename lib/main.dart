import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/game/game_widget.dart';

void main() {
  runApp(MaterialApp(
    home: GameWidget(),
    debugShowCheckedModeBanner: false,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
}
