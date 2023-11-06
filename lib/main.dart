import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wasla/Screens/DestinationPicker.dart';
import 'package:wasla/Screens/HomePage.dart';
import 'package:wasla/Screens/Login/PhoneLogin.dart';
import 'package:wasla/Screens/Maps/TaxiPage.dart';
import 'package:wasla/testsWidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wasala Andk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: TextTheme(bodyMedium: GoogleFonts.changa())),
      home: PhoneLogin(),
    );
  }
}
