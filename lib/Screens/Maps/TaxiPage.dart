import 'dart:async';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:wasla/Constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:lottie/lottie.dart' as animation;
import 'package:wasla/Models/Driver.dart';
import 'package:wasla/Models/Trip.dart';
import 'package:wasla/Models/User.dart';
import 'package:wasla/Screens/HomePage.dart';

class TaxiView extends StatefulWidget {
  const TaxiView(
      {super.key, required this.from, required this.to, required this.user});
  final GeocodingResult from;
  final GeocodingResult to;
  final User user;
  @override
  State<TaxiView> createState() => _TaxiViewState();
}

class _TaxiViewState extends State<TaxiView> {
  Position? userPosition;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  Set<Marker> _markers = Set<Marker>();
  bool loading = true;
  bool requested = false;
  bool found = false;
  List<LatLng> drivers = [];
  Trip? trip;
  late BitmapDescriptor carImage;
  late IO.Socket socket;

  @override
  void initState() {
    // TODO: implement initState
    initSocket();
    super.initState();
    getUserPosition();
    getCarImage();
    setListener();
    polylinePoints = PolylinePoints();
  }

  setListener() {
    socket.on("added", (data) {
      print("we connected");
    });
    socket.on("rideAccept", (data) {
      Trip result = Trip.fromJson(data['trip']);
      setState(() {
        trip = result;
        found = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          loading = false;
        });
      });
      setDriverPolylines(
          LatLng(trip!.driver!.latitude, trip!.driver!.longtitude));
    });
    socket.on("driverLocationUpdate", (data) {
      setState(() {
        trip!.driver = Driver.fromJson(data['driver']);
      });
      setDriverPolylines(
          LatLng(trip!.driver!.latitude, trip!.driver!.longtitude));
    });

    socket.on('endRide', (data) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
    });
  }

  cancelRide() {
    if (trip != null) {
      socket.emit("cancelRide", {"tripId": trip!.id});
    }
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
  }

  initSocket() async {
    socket = IO.io("http://192.168.169.132:5000", {
      "transports": ['websocket'],
      "autoConnect": false
    });
    socket.connect();
    // socket!.emit("add", widget.user.id);
    socket.emit("add", {"userId": widget.user.id});
  }

  getDriver() async {
    setState(() {
      requested = true;
    });
    socket.emit("rideRequest", {
      "wilaya": 25,
      "userId": widget.user.id,
      "cost": 300,
      "destinationLatitude": widget.to.geometry.location.lat,
      "destinationLongtitude": widget.to.geometry.location.lng,
      "pickUpLocationLatitude": widget.from.geometry.location.lat,
      "pickUpLocationLongtitude": widget.from.geometry.location.lng
    });
  }

  getCarImage() async {
    BitmapDescriptor customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(5, 10)), "assets/images/car.png");
    setState(() {
      carImage = customMarkerIcon;
    });
  }

  getUserPosition() async {
    Position location = await Geolocator.getCurrentPosition();
    setState(() {
      userPosition = location;
    });
  }

  void setRidePolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.apiKey,
      PointLatLng(
          widget.from.geometry.location.lat, widget.from.geometry.location.lng),
      PointLatLng(
          widget.to.geometry.location.lat, widget.to.geometry.location.lng),
    );

    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(Polyline(
            width: 10,
            polylineId: const PolylineId('polyLine'),
            color: const Color(0xFF08A5CB),
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
      PointLatLng(
          widget.from.geometry.location.lat, widget.from.geometry.location.lng),
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
            position: LatLng(widget.from.geometry.location.lat,
                widget.from.geometry.location.lng),
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
        position: LatLng(widget.from.geometry.location.lat,
            widget.from.geometry.location.lng),
      ));

      _markers.add(Marker(
        markerId: MarkerId('destinationPin'),
        position: LatLng(
            widget.to.geometry.location.lat, widget.to.geometry.location.lng),
      ));
    });
  }
  // giyrufuohfouy

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => showExitConfirmationDialog(context),
        child: Scaffold(
          body: !requested
              ? Stack(children: [
                  Expanded(child: map()),
                  Positioned(bottom: 0, child: _bottomContainer(context))
                ])
              : DraggableBottomSheet(
                  minExtent: 250,
                  useSafeArea: false,
                  curve: Curves.easeIn,
                  previewWidget: bottomContainer(context),
                  expandedWidget: expandedContainer(context),
                  backgroundWidget: map(),
                  maxExtent: MediaQuery.of(context).size.height * 0.8,
                  onDragging: (pos) {},
                ),
        ),
      ),
    );
  }

  showExitConfirmationDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Want to cancel the ride?'),
          content: Text('Do you want to exit the trip?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(
                    false); // Dismiss the dialog and prevent the back action.
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                cancelRide();
                Navigator.of(context)
                    .pop(true); // Dismiss the dialog and allow the back action.
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
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
      height: 200,
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
              getDriver();
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

  bottomContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.arrowUp, color: Colors.blueGrey[200]),
            const SizedBox(width: 5),
            const Text(
              "Your Driver",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 5),
            FaIcon(FontAwesomeIcons.arrowUp, color: Colors.blueGrey[200]),
          ],
        ),
        const SizedBox(height: 25),
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
                    "${trip != null ? trip!.driver!.firstName : ""} ${trip != null ? trip!.driver!.lastName : ""}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "0${trip != null ? trip!.driver!.phoneNumber : ""}",
                    style: const TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                print(trip!.driverId);
              },
              child: CircleAvatar(
                radius: 25,
                child: Center(child: FaIcon(FontAwesomeIcons.phone)),
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
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
                        "${trip != null ? trip!.driver!.firstName : ""} ${trip != null ? trip!.driver!.lastName : ""}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "0${trip != null ? trip!.driver!.phoneNumber : ""}",
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
              "${trip != null ? trip!.driver!.carBrand : ""} ${trip != null ? trip!.driver!.carName : ""}",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "${trip != null ? trip!.driver!.licensePlate : ""}",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            const Text(
              "Ride",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text(
              widget.from.formattedAddress!,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            FaIcon(FontAwesomeIcons.arrowDown),
            const SizedBox(height: 15),
            Text(
              widget.to.formattedAddress!,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              "Price",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              "${trip != null ? trip!.cost : ""} DA",
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
