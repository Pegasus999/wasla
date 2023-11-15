import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Test extends StatelessWidget {
  final List<IconData> icons = const [
    Icons.message,
    Icons.call,
    Icons.mail,
    Icons.notifications,
    Icons.settings,
  ];

  const Test({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(builder: (context) {
        return Scaffold(
            body: Center(
          child: SizedBox(
              width: 300,
              height: 300,
              child: LottieBuilder.asset("assets/animations/towtruck.json")),
        ));
      }),
    );
  }
}
