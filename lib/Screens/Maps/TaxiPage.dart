import 'dart:async';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:wasla/Constants.dart';
import 'package:lottie/lottie.dart' as animation;
import 'package:wasla/Services/API.dart';

class TaxiView extends StatefulWidget {
  const TaxiView({super.key, required this.from, required this.to});
  final GeocodingResult from;
  final GeocodingResult to;
  @override
  State<TaxiView> createState() => _TaxiViewState();
}

class _TaxiViewState extends State<TaxiView> {
  GeocodingResult from = GeocodingResult(
      geometry: Geometry(location: Location(lat: 36.2908, lng: 6.5264)),
      placeId: "");
  GeocodingResult to = GeocodingResult(
      geometry: Geometry(location: Location(lat: 36.2726, lng: 6.5056)),
      placeId: "");
  Position? userPosition;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  Set<Marker> _markers = Set<Marker>();
  bool loading = true;
  bool _loading = false;
  bool found = false;
  List<LatLng> drivers = [];
  late BitmapDescriptor carImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserPosition();
    getCarImage();
    polylinePoints = PolylinePoints();
  }

  getCarImage() async {
    BitmapDescriptor customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(5, 10)), "assets/images/car.png");
    setState(() {
      carImage = customMarkerIcon;
    });
  }

  getNearbyDrivers() async {
    List<LatLng> list = await API.getNearbyDrivers(
        LatLng(userPosition!.latitude, userPosition!.longitude));
    setState(() {
      drivers = list;
    });

    for (var driver in drivers.asMap().entries) {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId('driver${driver.key}'),
            position: driver.value,
            icon: carImage));
      });
    }
  }

  getUserPosition() async {
    Position location = await Geolocator.getCurrentPosition();
    setState(() {
      userPosition = location;
    });
    getNearbyDrivers();
  }

  void setRidePolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.apiKey,
      PointLatLng(from.geometry.location.lat, from.geometry.location.lng),
      PointLatLng(to.geometry.location.lat, to.geometry.location.lng),
    );

    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(Polyline(
            width: 10,
            polylineId: PolylineId('polyLine'),
            color: Color(0xFF08A5CB),
            points: polylineCoordinates));
      });
    }
  }

  void resetMap() async {
    setState(() {
      _markers = {};
      _polylines = {};
      polylineCoordinates = [];
    });
  }

  void setDriverPolylines(LatLng driver) async {
    resetMap();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.apiKey,
      PointLatLng(driver.latitude, driver.longitude),
      PointLatLng(from.geometry.location.lat, from.geometry.location.lng),
    );

    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _markers.addAll([
          Marker(
              markerId: MarkerId('driver'), position: driver, icon: carImage),
          Marker(
            markerId: MarkerId('destinationPin'),
            position:
                LatLng(from.geometry.location.lat, from.geometry.location.lng),
          )
        ]);
        _polylines.add(Polyline(
            width: 10,
            polylineId: PolylineId('driver'),
            color: Color(0xFF08A5CB),
            points: polylineCoordinates));
      });
    }
  }

  void showPinsOnMap() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position:
            LatLng(from.geometry.location.lat, from.geometry.location.lng),
      ));

      _markers.add(Marker(
        markerId: MarkerId('destinationPin'),
        position: LatLng(to.geometry.location.lat, to.geometry.location.lng),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: DraggableBottomSheet(
          minExtent: 150,
          useSafeArea: false,
          curve: Curves.easeIn,
          previewWidget:
              _loading ? bottomContainer(context) : _bottomContainer(context),
          expandedWidget: expandedContainer(context),
          backgroundWidget: map(),
          maxExtent: MediaQuery.of(context).size.height * 0.9,
          onDragging: (pos) {},
        ),
      ),
    );
  }

  map() {
    return userPosition != null
        ? GoogleMap(
            polylines: _polylines,
            markers: _markers,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                target: LatLng(userPosition!.latitude, userPosition!.longitude),
                zoom: 15),
            onMapCreated: (controller) {
              _controller.complete(controller);
              showPinsOnMap();
            },
          )
        : Constants.loading;
  }

  Container _bottomContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 250,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Your Ride",
            style: GoogleFonts.changa(fontSize: 20),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Price : ",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "300 Da",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _loading = true;
              });
              Future.delayed(
                const Duration(seconds: 10),
                () {
                  setState(() {
                    found = true;
                  });
                },
              );
              Future.delayed(
                const Duration(seconds: 12),
                () {
                  setState(() {
                    loading = false;
                  });
                },
              );
            },
            child: Text("Find a Driver"),
            style: ButtonStyle(
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)))),
          )
        ],
      ),
    );
  }

  Container bottomContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 250,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Colors.white),
      child: loading ? lookingForDriver() : driverPreview(),
    );
  }

  driverPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Your Driver",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Driver Name",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "0554805413",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 25,
              child: Center(child: FaIcon(FontAwesomeIcons.phone)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        FaIcon(
          FontAwesomeIcons.angleDown,
          color: Colors.black.withOpacity(0.3),
        )
      ],
    );
  }

  Container expandedContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Colors.white),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Your Driver",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Driver Name",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "0554805413",
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 25,
                  child: Center(child: FaIcon(FontAwesomeIcons.phone)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Car",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text(
              "Renault Symbol - Gris",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "303436 - 114 - 25",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            const Text(
              "Ride",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text(
              "Random ass address",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            FaIcon(FontAwesomeIcons.arrowDown),
            const SizedBox(height: 15),
            Text(
              "Random ass address",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              "Price",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              "300 DA",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  lookingForDriver() {
    return found
        ? Center(
            child: Text(
              "Driver Found!! ",
              style: TextStyle(fontSize: 26),
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Looking for a Driver nearby",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              animation.Lottie.asset("assets/animations/hotspot.json"),
            ],
          );
  }
}
