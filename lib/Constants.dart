import 'package:flutter/material.dart';

class Constants {
  static Color main = const Color.fromRGBO(91, 71, 114, 1);
  static Color mainLight = const Color.fromRGBO(162, 143, 185, 1);
  static Color mainLighter = const Color.fromRGBO(194, 180, 209, 1);
  static Color secondary = const Color.fromRGBO(216, 203, 197, 1);
  static Color secondaryDarker = const Color.fromRGBO(204, 188, 180, 1);
  static Color secondaryLight = const Color.fromRGBO(222, 211, 206, 1);
  static Color background = const Color.fromRGBO(235, 235, 235, 1);
  static Color black = const Color.fromRGBO(51, 51, 51, 1);

  static String apiKey = "AIzaSyASO5mgA_JBDA-MtJMg50m_bVjZy2f32jk";
  static List<Color> kDefaultRainbowColors = const [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];
  static Widget loading = const Center(
    child: CircularProgressIndicator(),
  );
}
