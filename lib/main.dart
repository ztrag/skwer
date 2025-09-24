import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/menu/menu_wrapper.dart';

void main() {
  runApp(MaterialApp(
    home: SafeArea(
      child: Theme(
        data: ThemeData(
          fontFamily: 'CourierPrime',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: skWhite),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: 'CourierPrime',
                fontSize: 20,
              ),
              backgroundColor: Colors.transparent, // Transparent background
              foregroundColor: skGreen, // Text color
            ),
          ),
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
