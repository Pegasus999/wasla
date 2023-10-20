import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wasla/Constants.dart';
import 'package:wasla/Services/API.dart';

class RepairPage extends StatefulWidget {
  const RepairPage({super.key, required this.position});
  final Position? position;
  @override
  State<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLng? selected;
  Set<Marker> _markers = Set<Marker>();
  List<LatLng> repaires = [];

  @override
  void initState() {
    super.initState();
    getRepaires();
  }

  getRepaires() async {
    List<LatLng> list = await API.getNearbyRepaires(
        LatLng(widget.position!.latitude, widget.position!.longitude));
    setState(() {
      repaires = list;
      selected = list[0];
    });
  }

  showPinsOnMap() async {
    for (var repair in repaires.asMap().entries) {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('driver${repair.key}'),
          position: repair.value,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [_map(), _bottomContrainer()],
          ),
        ),
      ),
    );
  }

  _map() {
    return GoogleMap(
      markers: _markers,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
          target: LatLng(widget.position!.latitude, widget.position!.longitude),
          zoom: 15),
      onMapCreated: (controller) {
        _controller.complete(controller);
        showPinsOnMap();
      },
    );
  }

  void openGoogleMaps() async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${selected!.latitude},${selected!.longitude}';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      await launchUrl(Uri.parse(
          "https://play.google.com/store/apps/details?id=com.google.android.apps.maps&pcampaignid=web_share"));
    }
  }

  _bottomContrainer() {
    return Positioned(
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(color: Constants.night),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Repair Title",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(
                height: 5,
                color: Colors.transparent,
              ),
              Text("Mond - Thur / 8 AM - 7 PM"),
              const Divider(
                height: 20,
                color: Colors.transparent,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: FaIcon(FontAwesomeIcons.phone),
                  ),
                  GestureDetector(
                    onTap: () => openGoogleMaps(),
                    child: CircleAvatar(
                      radius: 30,
                      child: FaIcon(FontAwesomeIcons.route),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
