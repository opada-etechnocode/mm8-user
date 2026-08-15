import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_fonts.dart';

Color _primaryColor = const Color(0xFF438faf);
Color _secondaryColor = const Color(0xFFF58300);

ThemeData light({
  Color? primaryColor,
  Color? secondaryColor,
  String? fontFamily,
}) {
  final family = fontFamily ?? AppFonts.defaultFont;

  return ThemeData(
    fontFamily: family,
    primaryColor: _primaryColor,
    brightness: Brightness.light,
    highlightColor: Colors.white,
    hintColor: const Color(0xFF6E6E6E),
    splashColor: Colors.transparent,
    cardColor: Colors.white,
    scaffoldBackgroundColor: const Color(0xFFF7F8FA),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: const Color(0xFF222324), fontFamily: family),
      bodyMedium: TextStyle(color: _primaryColor, fontFamily: family),
      bodySmall: TextStyle(color: const Color(0xFFA7A7A7), fontFamily: family),
      titleMedium: TextStyle(color: const Color(0xFF656566), fontFamily: family),
    ),

  colorScheme:  ColorScheme.light(
    primary: _primaryColor,  // Primary Color
    secondary: _secondaryColor,  // Secondary Color
    tertiary: const Color(0xFFFFBB38), // Warning Color
    tertiaryContainer: const Color(0xFFADC9F3),
    onTertiaryContainer: const Color(0xFF04BB7B), // Success Color
    onPrimary: const Color(0xFF7FBBFF),
    surface: const Color(0xFFF4F8FF),
    onSecondary: secondaryColor ?? const Color(0xFFF88030),
    error: const Color(0xFFFF4040), // Danger Color
    onSecondaryContainer: const Color(0xFFF3F9FF),
    outline: const Color(0xff5C8FFC), // Info Color
    onTertiary: const Color(0xFFE9F3FF),
    shadow: const Color(0xFF66717C),

    primaryContainer: const Color(0xFF9AECC6),
    secondaryContainer: const Color(0xFFE9EEF4),
  ),

  pageTransitionsTheme: PageTransitionsTheme(builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
    TargetPlatform.fuchsia: const CupertinoPageTransitionsBuilder(),
  }),
  );
}
