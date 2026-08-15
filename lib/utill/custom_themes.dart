import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_fonts.dart';
import 'package:provider/provider.dart';

TextStyle get titilliumRegular => TextStyle(
      fontFamily: AppFonts.current,
      fontSize: 12,
    );

TextStyle get titleRegular => TextStyle(
      fontFamily: AppFonts.current,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );

TextStyle get titleHeader => TextStyle(
      fontFamily: AppFonts.current,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );

TextStyle get titilliumSemiBold => TextStyle(
      fontFamily: AppFonts.current,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

TextStyle get titilliumBold => TextStyle(
      fontFamily: AppFonts.current,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    );

TextStyle get titilliumItalic => TextStyle(
      fontFamily: AppFonts.current,
      fontSize: 14,
      fontStyle: FontStyle.italic,
    );

TextStyle get textRegular => TextStyle(
      fontFamily: AppFonts.current,
      fontWeight: FontWeight.w300,
      fontSize: 14,
    );

TextStyle get textMedium => TextStyle(
      fontFamily: AppFonts.current,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

TextStyle get textBold => TextStyle(
      fontFamily: AppFonts.current,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

TextStyle get robotoBold => TextStyle(
      fontFamily: AppFonts.current,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    );

class ThemeShadow {
  static List<BoxShadow> getShadow(BuildContext context) {
    List<BoxShadow> boxShadow = [
      BoxShadow(
        color: Provider.of<ThemeController>(context, listen: false).darkTheme
            ? Colors.black26
            : Theme.of(context).primaryColor.withValues(alpha: .075),
        blurRadius: 5,
        spreadRadius: 1,
        offset: const Offset(1, 1),
      )
    ];
    return boxShadow;
  }
}
