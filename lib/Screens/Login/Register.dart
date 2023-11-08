import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasla/Constants.dart';
import 'package:wasla/Screens/HomePage.dart';
import 'package:wasla/Services/API.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.number});
  final String number;
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool loading = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController wilayaController = TextEditingController();

  register() async {
    final response = await API.register(context, widget.number,
        firstNameController.text, lastNameController.text);
    if (response != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> json = response!.toJson();
      await prefs.setString("user", jsonEncode(json));
      await prefs.setInt("wilaya", int.parse(wilayaController.text));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
                user: response, wilaya: int.parse(wilayaController.text)),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Constants.background,
        body: SingleChildScrollView(
          child: SizedBox(
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
                    height: 500,
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
                          "Register",
                          style: TextStyle(
                              fontSize: 24,
                              color: Constants.black,
                              fontWeight: FontWeight.w600),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Color.fromRGBO(184, 184, 184, 1)),
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Constants.black,
                                    fontWeight: FontWeight.bold),
                                controller: firstNameController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                    hintText: "First name",
                                    hintStyle: TextStyle(
                                        color:
                                            Constants.black.withOpacity(0.4))),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Color.fromRGBO(184, 184, 184, 1)),
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Constants.black,
                                    fontWeight: FontWeight.bold),
                                controller: lastNameController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                    hintText: "Last name",
                                    hintStyle: TextStyle(
                                        color:
                                            Constants.black.withOpacity(0.4))),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Color.fromRGBO(184, 184, 184, 1)),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Constants.black,
                                    fontWeight: FontWeight.bold),
                                controller: wilayaController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                    hintText: "Wilaya (e.g 25)",
                                    hintStyle: TextStyle(
                                        color:
                                            Constants.black.withOpacity(0.4))),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              if (firstNameController.text.isNotEmpty &&
                                  lastNameController.text.isNotEmpty &&
                                  int.tryParse(wilayaController.text) != null) {
                                register();
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Constants.main),
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16))),
                                minimumSize: MaterialStatePropertyAll(Size(
                                    MediaQuery.of(context).size.width, 50))),
                            child: loading
                                ? Constants.loading
                                : Text(
                                    "Login",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
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
      ),
    );
  }
}
