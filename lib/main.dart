import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/menu/menu_wrapper.dart';

void main() {
  runApp(MaterialApp(
    home: SafeArea(
      child: Theme(
        data: ThemeData(
          fontFamily: 'CourierPrime',
        ),
        child: const MenuWrapper(),
      ),
    ),
    debugShowCheckedModeBanner: false,
  ));
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black, // navigation bar color
    statusBarColor: Colors.black, // status bar color
  ));
}
