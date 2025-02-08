import 'package:flutter/material.dart';

TextStyle style(double fontSize, {required Color color}) {
  return TextStyle(
    fontSize: fontSize,
    fontFamily: 'PlayfairDisplay',
    fontWeight: FontWeight.bold,
    color: color,
  );
}

TextStyle style1(double fontSize, {required Color color}) {
  return TextStyle(
    fontSize: fontSize,
    fontFamily: 'Merriweather',
    fontWeight: FontWeight.bold,
    color: color,
  );
}

TextStyle style2(double fontSize, {required Color color}) {
  return TextStyle(
    fontSize: fontSize,
    fontFamily: 'times new roman',
    fontWeight: FontWeight.bold,
    color: color,
  );
}
