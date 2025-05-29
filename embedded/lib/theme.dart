import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const textColor = Color(0xFF373739);
const primaryColor = Color(0xFF4D7DFA);
const backgroundColor = Color(0xFFF9FAFC);
const grayColor = Color(0xFFE6E8EC);

final textTheme = TextTheme(
  headlineMedium: GoogleFonts.manrope(
    color: textColor,
    fontSize: 32,
    fontWeight: FontWeight.w700,
  ),
  headlineSmall: GoogleFonts.manrope(
    color: textColor,
    fontSize: 26,
    fontWeight: FontWeight.w600,
  ),
  bodyLarge: GoogleFonts.manrope(
    color: textColor,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
  bodyMedium: GoogleFonts.manrope(
    color: textColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  ),
  bodySmall: GoogleFonts.manrope(
    color: textColor,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.01,
  ),
);

const appBarTheme = AppBarTheme(
  backgroundColor: Colors.white,
  foregroundColor: textColor,
  surfaceTintColor: Colors.white,
  elevation: 1,
  shadowColor: Colors.black12,
  systemOverlayStyle: SystemUiOverlayStyle.dark,
  titleTextStyle: TextStyle(
    color: textColor,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  ),
);

final cardTheme = CardThemeData(
  color: Colors.white,
  elevation: 15,
  shadowColor: Colors.black26,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
);

final elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 48),
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(
      vertical: 9,
      horizontal: 24,
    ),
    textStyle: GoogleFonts.manrope(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.01,
    ),
  ),
);

final appTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: backgroundColor,
  dividerTheme: const DividerThemeData(
    color: grayColor,
    thickness: 1,
    space: 0,
  ),
  textTheme: textTheme,
  appBarTheme: appBarTheme,
  cardTheme: cardTheme,
  elevatedButtonTheme: elevatedButtonTheme,
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: primaryColor,
  ),
);
