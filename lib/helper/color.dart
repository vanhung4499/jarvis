import 'package:flutter/material.dart';

// Convert color to string
String colorToString(Color color) {
  try {
    return color.toString().split('(0x')[1].split(')')[0];
  } catch (e) {
    return '000000';
  }
}

// Convert string to color
Color stringToColor(String colorString) {
  try {
    return Color(int.parse(colorString, radix: 16));
  } catch (e) {
    return Colors.black;
  }
}
