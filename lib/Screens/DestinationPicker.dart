import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Maps/TaxiPage.dart';
import 'package:wasla/Constants.dart';
import 'package:map_location_picker/map_location_picker.dart';

class DestinationPage extends StatefulWidget {
  const DestinationPage(
      {super.key, required this.position, required this.location});
  final Position? position;
  final location;
  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  Position? userPosition;
  GeocodingResult? from;
  GeocodingResult? to;
  List<GeocodingResult> recents = [];
  List<GeocodingResult> favorites = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRecentPlaces();
    getFavoritePlaces();
    setState(() {
      userPosition = widget.position;
      from = GeocodingResult.fromJson(widget.location);
    });
  }

  getRecentPlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList("recents") ?? [];
    List<GeocodingResult> objects =
        list.map((e) => GeocodingResult.fromJson(jsonDecode(e))).toList();
    if (objects.isNotEmpty) {
      setState(() {
        recents = objects;
      });
    }
  }

  getFavoritePlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList("favorites") ?? [];
    List<GeocodingResult> objects =
        list.map((e) => GeocodingResult.fromJson(jsonDecode(e))).toList();
    if (objects.isNotEmpty) {
      setState(() {
        favorites = objects;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Constants.grey,
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Center(child: FaIcon(FontAwesomeIcons.angleLeft))),
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Location',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Constants.grey,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                60,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                locationsInputs(context),
                const SizedBox(height: 20),
                savedPlaces(context),
                const SizedBox(height: 20),
                recentPlaces(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Flexible recentPlaces(BuildContext context) {
    return Flexible(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 50,
        child: Column(
          children: [
            const Text(
              "Recents",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            Flexible(
              child: SizedBox(
                  child: recents.isEmpty
                      ? const Center(
                          child: Text("No History Yet"),
                        )
                      : ListView.separated(
                          itemBuilder: (context, index) => _recents(index),
                          separatorBuilder: (context, index) => const Divider(
                                color: Colors.transparent,
                              ),
                          itemCount: recents.length)),
            ),
          ],
        ),
      ),
    );
  }

  Container savedPlaces(BuildContext context) {
    return Container(
      height: 170,
      width: MediaQuery.of(context).size.width - 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 40,
            child: Text(
              "Saved Places",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline),
            ),
          ),
          Flexible(
            child: SizedBox(
              child: favorites.isEmpty
                  ? const Center(
                      child: Text("No Favorites Yet"),
                    )
                  : ListView.separated(
                      itemBuilder: (context, index) => _favorites(),
                      separatorBuilder: (context, index) => const Divider(
                            color: Colors.transparent,
                          ),
                      itemCount: favorites.length),
            ),
          ),
        ],
      ),
    );
  }

// make it that when a recent place is clicked , it checks if the first field is filled it goes into the second if not then it goes to the first !
  _recents(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: GestureDetector(
        onTap: () {},
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.locationDot,
                size: 35,
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 230,
                    child: Text(
                      "Crazy",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  SizedBox(
                    width: 230,
                    child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: const TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(text: "3.6km"),
                              TextSpan(text: " | "),
                              TextSpan(
                                text: "Some random ass Address",
                              )
                            ])),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _favorites() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: const FaIcon(
                FontAwesomeIcons.house,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Home",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 210,
                  child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: const TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(text: "3.6km"),
                            TextSpan(text: " | "),
                            TextSpan(
                              text: "Some random ass Address",
                            )
                          ])),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Column locationsInputs(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapLocationPicker(
                  hideMapTypeButton: true,
                  hideSuggestionsOnKeyboardHide: true,
                  hideMoreOptions: true,
                  apiKey: Constants.apiKey,
                  onNext: (GeocodingResult? result) {
                    if (result != null) {
                      setState(() {
                        from = result;
                      });
                      if (to != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaxiView(from: result, to: to!),
                            ));
                      } else {
                        Navigator.pop(context);
                      }
                    }
                  },
                  region: 'dz',
                  currentLatLng:
                      LatLng(userPosition!.latitude, userPosition!.longitude),
                ),
              )),
          child: Container(
            width: MediaQuery.of(context).size.width - 50,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(30)),
            child: Text(from != null
                ? from!.formattedAddress!.toString()
                : "Select pick up location"),
          ),
        ),
        const SizedBox(
          height: 50,
          child: Center(child: FaIcon(FontAwesomeIcons.angleDown)),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapLocationPicker(
                  hideMapTypeButton: true,
                  hideSuggestionsOnKeyboardHide: true,
                  hideMoreOptions: true,
                  apiKey: Constants.apiKey,
                  onNext: (GeocodingResult? result) {
                    if (result != null) {
                      setState(() {
                        to = result;
                      });
                      if (from != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaxiView(from: from!, to: result),
                            ));
                      } else {
                        Navigator.pop(context);
                      }
                    }
                  },
                  region: 'dz',
                  currentLatLng:
                      LatLng(userPosition!.latitude, userPosition!.longitude),
                ),
              )),
          child: Container(
            width: MediaQuery.of(context).size.width - 50,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(30)),
            child:
                Text(to != null ? to!.formattedAddress! : "Select Destination"),
          ),
        ),
      ],
    );
  }
}
