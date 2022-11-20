import 'package:flutter/material.dart';

class CustomThemes {
  static ThemeData darkMode = ThemeData(
    colorScheme: ColorScheme(
      primary: Colors.amber,
      onPrimary: Colors.white,
      secondary: Colors.teal,
      onSecondary: Colors.white,
      surface: Colors.grey.shade900,
      background: Colors.grey.shade900,
      error: Colors.red.shade400,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.amber;
        }
        return Colors.grey.shade600;
      }),
      trackColor: MaterialStateProperty.all(Colors.grey.shade500),
    ),
  );

  static ThemeData lightMode = ThemeData(
    colorScheme: ColorScheme(
      primary: Colors.amber,
      onPrimary: Colors.white,
      secondary: Colors.teal,
      onSecondary: Colors.white,
      surface: Colors.grey.shade900,
      background: Colors.grey.shade200,
      error: Colors.red.shade400,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.amber;
        }
        return Colors.grey.shade600;
      }),
      trackColor: MaterialStateProperty.all(Colors.grey.shade500),
    ),
  );
}

