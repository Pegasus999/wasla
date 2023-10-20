import 'package:flutter/material.dart';

class Constants {
  static Color darkYellow = const Color.fromRGBO(228, 182, 26, 1);
  static Color lightYellow = const Color.fromRGBO(251, 225, 52, 1);
  static Color grey = const Color.fromRGBO(233, 234, 236, 1);
  static Color darkGrey = const Color.fromRGBO(42, 46, 52, 1);
  static Color night = const Color.fromRGBO(20, 21, 21, 1);
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
