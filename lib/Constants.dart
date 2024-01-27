import 'package:flutter/material.dart';

class Constants {
  static Color background = const Color.fromRGBO(254, 255, 248, 1);
  static Color orangeLight = const Color.fromRGBO(244, 178, 102, 1);
  static Color greenPop = const Color.fromRGBO(146, 189, 143, 1);
  static Color orangePop = const Color.fromRGBO(226, 146, 54, 1);
  static Color greenBack = const Color.fromRGBO(221, 231, 199, 1);
  static Color black = const Color.fromRGBO(51, 51, 51, 1);
  static Color red = const Color.fromRGBO(178, 22, 30, 1);
  static Color grey = const Color.fromRGBO(197, 197, 197, 1);


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
