import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wasla/Models/User.dart';
import 'Maps/TaxiPage.dart';
import 'package:wasla/Constants.dart';
import 'package:map_location_picker/map_location_picker.dart';

class DestinationPage extends StatefulWidget {
  const DestinationPage(
      {super.key,
      required this.position,
      required this.location,
      required this.wilaya,
      required this.user});
  final Position? position;
  final User user;
  final int wilaya;
  final location;
  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  Position? userPosition;
  GeocodingResult? from;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  GeocodingResult? to;
  Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      userPosition = widget.position;
      from = GeocodingResult.fromJson(widget.location);
      _markers.add(Marker(
          markerId: MarkerId('user'),
          position:
              LatLng(widget.position!.latitude, widget.position!.longitude)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Constants.background,
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: Container(
            margin: const EdgeInsets.only(top: 10),
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              child: const Center(child: FaIcon(FontAwesomeIcons.arrowLeft)),
            )),
        body: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [_map(), _bottomContrainer()],
          ),
        ),
      ),
    );
  }

  _map() {
    return userPosition != null
        ? GoogleMap(
            mapType: MapType.normal,
            markers: _markers,
            initialCameraPosition: CameraPosition(
                target: LatLng(userPosition!.latitude, userPosition!.longitude),
                zoom: 10),
            onMapCreated: (controller) async {
              _controller.complete(controller);
              await controller.animateCamera(CameraUpdate.newLatLngZoom(
                LatLng(userPosition!.latitude, userPosition!.longitude),
                15,
              ));
            },
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  _bottomContrainer() {
    return Positioned(
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 150,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Where do you want to go?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter your destination down below",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaxiView(
                                      from: from!,
                                      to: result,
                                      user: widget.user),
                                ));
                          }
                        },
                        region: 'dz',
                        currentLatLng: LatLng(
                            userPosition!.latitude, userPosition!.longitude),
                      ),
                    ),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        border: Border.all(color: Constants.black),
                        borderRadius: BorderRadius.circular(30)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.mapLocation),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text("Pick Destination"),
                        ),
                        FaIcon(FontAwesomeIcons.angleRight)
                      ],
                    ),
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
