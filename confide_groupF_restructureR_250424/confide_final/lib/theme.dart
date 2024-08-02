import 'package:flutter/material.dart';

MaterialColor PrimaryMaterialColor = const MaterialColor(
  4283444623,
  <int, Color>{
    50: Color.fromRGBO(
      80,
      45,
      143,
      .1,
    ),
    100: Color.fromRGBO(
      3,
      183,
      238,
      1.0,
    ),
    200: Color.fromRGBO(
      61,
      164,
      220,
      1.0,
    ),
    300: Color.fromRGBO(
      3,
      183,
      238,
      1.0,
    ),
    400: Color.fromRGBO(
      3,
      183,
      238,
      1.0,
    ),
    500: Color.fromRGBO(
      3,
      183,
      238,
      1.0,
    ),
    600: Color.fromRGBO(
      3,
      183,
      238,
      1.0,
    ),
    700: Color.fromRGBO(
      3,
      183,
      238,
      1.0,
    ),
    800: Color.fromRGBO(
      3,
      183,
      238,
      1.0,
    ),
    900: Color.fromRGBO(
      3,
      183,
      238,
      1.0,
    ),
  },
);

ThemeData myTheme = ThemeData(
  fontFamily: "customFont",
  primaryColor: const Color(0xff03b7ee),
  // buttonColor: Color(0xff502d8f),
  // accentColor: Color(0xff502d8f),

  primarySwatch: PrimaryMaterialColor,

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        const Color(0xff03b7ee),
      ),
    ),
  ),
);
