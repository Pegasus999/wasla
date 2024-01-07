import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:wasla/Constants.dart';
import 'package:wasla/Models/User.dart';
import 'package:flutter/services.dart';
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
  int wilaya = 1;

  @override
  void initState() {
    super.initState();
    skipLogin();
  }

  skipLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? str = prefs.getString("user");

    if (str != null) {
      Map<String, dynamic> json = jsonDecode(str);
      User user = User.fromJson(json);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: user),
          ));
    } else {
      Future.delayed(
          const Duration(seconds: 2), () => showWilayaDialog(context));
    }
  }

  showWilayaDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => WilayaPicker(callback: (value) {
        setState(() {
          wilaya = value;
        });
      }),
    );
  }

  _login() async {
    try {
      User? result = await API.login(context, phoneController.text);
      print(result);
      if (result != null) {
        setState(() {
          loading = false;
          user = result;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Map<String, dynamic> json = user!.toJson();
        await prefs.setString("user", jsonEncode(json));
        await prefs.setInt("wilaya", wilaya);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                user: user!,
                wilaya: wilaya,
              ),
            ));
      } else {
        setState(() {
          loading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterPage(
                number: phoneController.text,
                wilaya: wilaya,
              ),
            ));
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("ERROR"),
          content:
              SizedBox(height: 200, child: Center(child: Text(e.toString()))),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Constants.secondaryDarker,
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
                                  color: Colors.white),
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
                                    color: Colors.white),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Constants.black,
                                      fontWeight: FontWeight.bold),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(9),
                                  ],
                                  controller: phoneController,
                                  onChanged: (value) => setState(() {
                                    phoneController.text = value;
                                  }),
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
                            if (phoneController.text.length == 9) {
                              setState(() {
                                loading = true;
                              });
                              _login();
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  phoneController.text.length == 9
                                      ? Constants.main
                                      : Constants.main.withOpacity(0.4)),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16))),
                              minimumSize: MaterialStatePropertyAll(
                                  Size(MediaQuery.of(context).size.width, 50))),
                          child: loading
                              ? Constants.loading
                              : const Text(
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
    );
  }
}

class WilayaPicker extends StatefulWidget {
  const WilayaPicker({super.key, required this.callback});
  final Function(int) callback;
  @override
  State<WilayaPicker> createState() => _WilayaPickerState();
}

class _WilayaPickerState extends State<WilayaPicker> {
  int wilaya = 25;
  List<String> wilayat = [
    'Adrar',
    'Chlef',
    'Laghouat',
    'Oum El Bouaghi',
    'Batna',
    'Béjaïa',
    'Biskra',
    'Béchar',
    'Blida',
    'Bouïra',
    'Tamanrasset',
    'Tébessa',
    'Tlemcen',
    'Tiaret',
    'Tizi Ouzou',
    'Algiers',
    'Djelfa',
    'Jijel',
    'Sétif',
    'Saïda',
    'Skikda',
    'Sidi Bel Abbès',
    'Annaba',
    'Guelma',
    'Constantine',
    'Médéa',
    'Mostaganem',
    "M'Sila",
    'Mascara',
    'Ouargla',
    'Oran',
    'El Bayadh',
    'Illizi',
    'Bordj Bou Arréridj',
    'Boumerdès',
    'El Tarf',
    'Tindouf',
    'Tissemsilt',
    'El Oued',
    'Khenchela',
    'Souk Ahras',
    'Tipaza',
    'Mila',
    'Aïn Defla',
    'Naâma',
    'Aïn Témouchent',
    'Ghardaïa',
    'Relizane',
    'Timimoun',
    'Bordj Badji Mokhtar',
    'Ouled Djellal',
    'Béni Abbès',
    'Ain Salah',
    'Ain Guezzam',
    'Touggourt',
    'Djanet',
    "El M'Ghair",
    'El Menia'
  ];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NumberPicker(
              value: wilaya,
              minValue: 1,
              maxValue: 58,
              step: 1,
              itemHeight: 100,
              axis: Axis.horizontal,
              onChanged: (value) {
                setState(() => wilaya = value);
                widget.callback(value);
              },
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(() {
                    final newValue = wilaya - 1;
                    wilaya = newValue.clamp(1, 58);
                  }),
                ),
                const SizedBox(
                  width: 40,
                ),
                Text(
                  'Wilaya: ${wilayat[wilaya - 1]}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  width: 40,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() {
                    final newValue = wilaya + 1;
                    wilaya = newValue.clamp(1, 58);
                  }),
                ),
              ],
            ),
          ]),
    );
  }
}
