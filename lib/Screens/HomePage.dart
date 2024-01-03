// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasla/Constants.dart';
import 'package:wasla/Models/Shop.dart';
import 'package:wasla/Models/Trip.dart';
import 'package:wasla/Models/User.dart';
import 'package:wasla/Screens/CarPicker.dart';
import 'package:wasla/Screens/DestinationPicker.dart';
import 'package:wasla/Screens/Login/PhoneLogin.dart';
import 'package:wasla/Screens/Maps/ShopPage.dart';
import 'package:wasla/Screens/Maps/TaxiPage.dart';
import 'package:wasla/Screens/Maps/TowingPage.dart';
import 'package:wasla/Services/API.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({super.key, required this.user});
  User user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? userPosition;
  Map<String, dynamic> address = {};
  int wilaya = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _handleLocationPermission();
    checkTrip();
    getWilaya();
    checkPosition();
  }

  checkTrip() async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${API.base_url}client/checkTrip');
      final body = jsonEncode({'userId': widget.user.id});
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        Trip trip = Trip.fromJson(json['trip']);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TaxiView(user: widget.user, wilaya: wilaya, trip: trip),
            ),
            (route) => false);
      }
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const SizedBox(
              height: 50,
              child: Text('An error occured, please check your internet'),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    checkTrip();
                  },
                  child: const Text("Retry"))
            ]),
      );
    }
  }

  getWilaya() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? number = prefs.getInt("wilaya");
    if (number != null) {
      setState(() {
        wilaya = number;
      });
    } else {
      showWilayaDialog(context);
    }
  }

  checkPosition() {
    Future.delayed(
      const Duration(seconds: 40),
      () {
        if (userPosition == null) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Error Occured"),
                content: const SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                          "Please check your internet connection and turn on your GPS location"),
                    )),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Future.delayed(const Duration(seconds: 10), () {
                          getUserPosition();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Retry"))
                ],
              ),
            );
            checkPosition();
          }
        }
      },
    );
  }

  getUserPosition() async {
    if (userPosition == null) {
      Position? location;
      try {
        location = await Geolocator.getCurrentPosition();
      } catch (e) {
        // Handle any errors that may occur when getting the location.
        print("Error getting user location: $e");
      }

      Map<String, dynamic> result =
          await API.getAddress(location!.latitude, location.longitude);
      if (result['error'] == null) {
        if (mounted) {
          setState(() {
            userPosition = location!;
            address = result;
          });
        }
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Constants.background,
        body: userPosition != null
            ? SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Location :",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  address['formatted_address'] ?? "",
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              showWilayaDialog(context);
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Constants.main,
                              child: Center(
                                  child: Text(
                                wilaya.toString(),
                                style: const TextStyle(color: Colors.white),
                              )),
                            ),
                          )
                        ],
                      ),
                      const Divider(
                        color: Colors.transparent,
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome!",
                                style: TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "What services would you like to use today?",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.transparent,
                        height: 20,
                      ),
                      Expanded(
                        child: GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setInt("wilaya", wilaya);
                            },
                            child: GridView(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 1.1,
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10),
                              children: [
                                _card(
                                    "Taxi",
                                    "assets/images/taxi.png",
                                    DestinationPage(
                                        position: userPosition,
                                        location: address,
                                        user: widget.user,
                                        wilaya: wilaya)),
                                _card(
                                    "Towing",
                                    "assets/images/towing.png",
                                    TowingView(
                                      position: userPosition,
                                      user: widget.user,
                                    )),
                                Opacity(
                                  opacity: 0.5,
                                  child: _card(
                                    "CarWash",
                                    "assets/images/carwash.png",
                                    ShopPage(
                                        position: userPosition,
                                        wilaya: wilaya,
                                        type: ShopType.carwash),
                                  ),
                                ),
                                Opacity(
                                  opacity: 0.5,
                                  child: _card(
                                    "Mechanic",
                                    "assets/images/mechanic.png",
                                    ShopPage(
                                        position: userPosition,
                                        wilaya: wilaya,
                                        type: ShopType.mechanic),
                                  ),
                                ),
                                Opacity(
                                  opacity: 0.5,
                                  child: _card(
                                    "Pieces",
                                    "assets/images/parts.png",
                                    const CarPicker(),
                                  ),
                                ),
                                Opacity(
                                  opacity: 0.5,
                                  child: _card(
                                    "Tolier",
                                    "assets/images/tolier.png",
                                    ShopPage(
                                      position: userPosition,
                                      wilaya: wilaya,
                                      type: ShopType.tollier,
                                    ),
                                  ),
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: SizedBox(
                    width: 50,
                    child: LoadingIndicator(
                      indicatorType: Indicator.lineScalePulseOut,
                      strokeWidth: 2,
                      colors: Constants.kDefaultRainbowColors,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, please enable it from settings.')));
      return false;
    }
    getUserPosition();
    return true;
  }

  _card(String label, String image, Widget widget) {
    return GestureDetector(
      onTap: () {
        if (label == "Taxi" || label == "Towing") {
          if (userPosition != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => widget,
                ));
          }
        }
      },
      child: Column(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Constants.black),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(child: Image.asset(image)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  showWilayaDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => WilayaPicker(callback: (value) {
        setState(() {
          wilaya = value;
        });
        saveWilaya(value);
      }),
    );
  }
}

saveWilaya(int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt("wilaya", value);
}
