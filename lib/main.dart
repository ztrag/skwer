import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/menu/menu_wrapper.dart';

void main() {
  runApp(const MaterialApp(
    home: SafeArea(
        child: DefaultTextStyle(
      style: TextStyle(fontSize: 16, fontFamily: 'CourierPrime'),
      child: MenuWrapper(),
    )),
    debugShowCheckedModeBanner: false,
  ));
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black, // navigation bar color
    statusBarColor: Colors.black, // status bar color
  ));
}
