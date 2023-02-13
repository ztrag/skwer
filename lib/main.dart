import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/game/game_widget.dart';

void main() {
  runApp(const MaterialApp(
    home: SafeArea(child: GameWidget()),
    debugShowCheckedModeBanner: false,
  ));
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black, // navigation bar color
    statusBarColor: Colors.black, // status bar color
  ));
}
