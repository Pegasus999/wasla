import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wasla/Constants.dart';
import 'package:wasla/Models/Shop.dart';
import 'package:wasla/Models/User.dart';
import 'package:wasla/Screens/CarPicker.dart';
import 'package:wasla/Screens/DestinationPicker.dart';
import 'package:wasla/Screens/Maps/ShopPage.dart';
import 'package:wasla/Screens/Maps/TowingPage.dart';
import 'package:wasla/Services/API.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({super.key, this.user, this.wilaya});
  User? user;
  int? wilaya;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? userPosition;
  Map<String, dynamic> address = {};
  int? wilaya = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _handleLocationPermission();
    setState(() {
      wilaya = widget.wilaya;
    });
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

      if (mounted) {
        setState(() {
          userPosition = location!;
          address = result;
        });
      }
    }
  }

  showNumberInputDialog(BuildContext context) async {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter a Wilaya'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  setState(() {
                    wilaya = int.tryParse(text);
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
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
                              showNumberInputDialog(context);
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
                                    user: widget.user!,
                                    wilaya: wilaya!)),
                            _card(
                                "Towing",
                                "assets/images/towing.png",
                                TowingView(
                                  position: userPosition,
                                  user: widget.user!,
                                )),
                            _card(
                                "CarWash",
                                "assets/images/carwash.png",
                                ShopPage(
                                    position: userPosition,
                                    wilaya: wilaya!,
                                    type: ShopType.carwash)),
                            _card(
                                "Mechanic",
                                "assets/images/mechanic.png",
                                ShopPage(
                                    position: userPosition,
                                    wilaya: wilaya!,
                                    type: ShopType.mechanic)),
                            _card("Pieces", "assets/images/parts.png",
                                const CarPicker()),
                            _card(
                                "Tolier",
                                "assets/images/tolier.png",
                                ShopPage(
                                  position: userPosition,
                                  wilaya: wilaya!,
                                  type: ShopType.tollier,
                                )),
                          ],
                        ),
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
      Future.delayed(
          const Duration(seconds: 30), () => _handleLocationPermission());
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        Future.delayed(
            const Duration(seconds: 2), () => _handleLocationPermission());
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, please enable it from settings.')));
      Future.delayed(
          const Duration(seconds: 2), () => _handleLocationPermission());
      return false;
    }
    getUserPosition();
    return true;
  }

  _card(String label, String image, Widget widget) {
    return GestureDetector(
      onTap: () {
        if (userPosition != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => widget,
              ));
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
}
