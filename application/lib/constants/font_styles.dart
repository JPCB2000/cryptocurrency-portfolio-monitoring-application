import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontStyles {
  static TextStyle montserratStyle(double fontSize, {Color color = Colors.white, FontWeight fontWeight = FontWeight.normal}) {
    return GoogleFonts.montserrat(
      textStyle: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight
      ),
    );
  }
}