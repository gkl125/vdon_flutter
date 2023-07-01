import 'package:flutter/material.dart';

Color ninjaDarkBlue = Color(0xff141926);
Color ninjaPrimaryColor = Color(0xFF0F131D);
Color ninjaBackgroundColor = Color(0xff141926);
Color ninjaCardColor = Color(0xffdddddd);

var theme = ThemeData(
  primaryColor: ninjaPrimaryColor,
  cardTheme: CardTheme(color: ninjaCardColor, elevation: 1),
  canvasColor: ninjaDarkBlue,
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 25.0, fontWeight: FontWeight.normal),
    displayMedium: TextStyle(fontSize: 15.0, color: Colors.red),
    displaySmall: TextStyle(fontSize: 15.0, color: Colors.white),
  ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: ninjaPrimaryColor).copyWith(background: ninjaBackgroundColor),
);
