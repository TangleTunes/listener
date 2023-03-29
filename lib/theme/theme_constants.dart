import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const COLOR_PRIMARY = Color(0xFF131925);
const COLOR_SECONDARY = Color(0xFFF3EFEE);
const COLOR_TERTIARY = Color(0xFFFF741E);
const COLOR_QUATERNARY = Color.fromRGBO(238, 191, 162, 1);

const BOLD_TEXT_STYLE = TextStyle(fontWeight: FontWeight.bold);

ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: COLOR_PRIMARY,
    textTheme: GoogleFonts.poppinsTextTheme());
