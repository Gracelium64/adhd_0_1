import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static final darkTheme = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.lightTeal,
      brightness: Brightness.dark,
    ),
    textTheme: baseTextTheme,
    // textTheme: darkTextTheme,
  );

  static final TextTheme baseTextTheme = TextTheme(
    bodyLarge: TextStyle(color: Palette.basicBitchBlack),
    bodyMedium: TextStyle(
      color: Palette.basicBitchWhite,
      fontFamily: 'Inter',
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: Palette.basicBitchWhite,
      fontFamily: 'Marvel',
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    displayLarge: TextStyle(),
    displayMedium: TextStyle(
      color: Palette.basicBitchWhite,
      fontFamily: 'Marvel',
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(),
    headlineLarge: TextStyle(
      fontFamily: 'Lobster',
      fontSize: 30,
      color: Palette.basicBitchWhite,
    ),
    headlineMedium: TextStyle(
      color: Palette.basicBitchWhite,
      fontFamily: 'Marvel',
      fontSize: 34,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: TextStyle(),
    labelLarge: TextStyle(),
    labelMedium: TextStyle(),
    labelSmall: TextStyle(
      color: Palette.basicBitchWhite,
      fontFamily: 'Inter',
      fontSize: 8,
    ),
    titleLarge: TextStyle(
      color: Palette.basicBitchWhite,
      fontFamily: 'Marvel',
      fontSize: 40,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: TextStyle(),
    titleSmall: TextStyle(
      color: Palette.basicBitchWhite,
      fontFamily: 'Inter',
      fontSize: 10,
    ),
  );

  // static final TextTheme darkTextTheme = baseTextTheme.apply();
}
