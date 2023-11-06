import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wasla/Constants.dart';
import 'package:wasla/Models/User.dart';
import 'package:wasla/Screens/HomePage.dart';
import 'package:wasla/Screens/Login/Register.dart';
import 'package:wasla/Services/API.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  TextEditingController phoneController = TextEditingController();
  User? user;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    skipLogin();
  }

  skipLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? str = await prefs.getString("user");
    int? wilayaStr = await prefs.getInt("wilaya");

    print(str);
    if (str != null) {
      Map<String, dynamic> json = jsonDecode(str);
      User user = User.fromJson(json);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: user, wilaya: wilayaStr!),
          ));
    }
  }

  _login() async {
    final result = await API.login(context, phoneController.text);
    if (result != null) {
      setState(() {
        user = result;
      });
      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Map<String, dynamic> json = user!.toJson();
        await prefs.setString("user", jsonEncode(json));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(user: user),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterPage(number: phoneController.text),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Constants.background,
        body: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  width: 200,
                  child: Center(
                    child: Image.asset("assets/images/logo.png"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Constants.secondary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 24,
                            color: Constants.black,
                            fontWeight: FontWeight.w600),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(children: [
                            Container(
                              height: 50,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color:
                                      const Color.fromRGBO(184, 184, 184, 1)),
                              child: const Center(
                                  child: Text(
                                "+213",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              )),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color:
                                        const Color.fromRGBO(184, 184, 184, 1)),
                                child: TextField(
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Constants.black,
                                      fontWeight: FontWeight.bold),
                                  controller: phoneController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 16),
                                      hintText: "Phone number",
                                      hintStyle: TextStyle(
                                          color: Constants.black
                                              .withOpacity(0.4))),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            _login();
                            setState(() {
                              loading = true;
                            });
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Constants.main),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16))),
                              minimumSize: MaterialStatePropertyAll(
                                  Size(MediaQuery.of(context).size.width, 50))),
                          child: loading
                              ? Constants.loading
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(184, 184, 184, 1)),
                                ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
