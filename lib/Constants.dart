import 'package:flutter/material.dart';

class Constants {
  static Color main = const Color.fromRGBO(255, 147, 118, 1);
  static Color mainLight = const Color.fromRGBO(162, 143, 185, 1);
  static Color mainLighter = const Color.fromRGBO(194, 180, 209, 1);
  static Color secondary = const Color.fromRGBO(141, 170, 166, 1);
  static Color secondaryDarker = const Color.fromRGBO(204, 188, 180, 1);
  static Color secondaryLight = Color.fromARGB(255, 128, 93, 73);
  static Color background = const Color.fromRGBO(235, 235, 235, 1);
  static Color black = const Color.fromRGBO(51, 51, 51, 1);

  static String apiKey = "AIzaSyCU0tk4IKjnadlWWgBGYp95nQsLe1-dedU";
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
