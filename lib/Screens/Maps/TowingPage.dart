import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:map_location_picker/map_location_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wasla/Constants.dart';
import 'package:wasla/Models/User.dart';
import 'package:wasla/Services/API.dart';

class TowingView extends StatefulWidget {
  const TowingView({super.key, required this.position, required this.user});
  final Position? position;
  final User user;
  @override
  State<TowingView> createState() => TowingViewState();
}

class TowingViewState extends State<TowingView>
    with SingleTickerProviderStateMixin {
  bool agreed = false;
  bool found = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late PolylinePoints polylinePoints;
  late AnimationController animationController;
  late BitmapDescriptor carImage;
  Position? userPosition;
  late LatLng towTruck;
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  Set<Marker> _markers = Set<Marker>();
  late IO.Socket socket;

  @override
  void initState() {
    // TODO: implement initState
    initSocket();
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Adjust the duration as needed
    );
    setListener();
    getCarImage();
    polylinePoints = PolylinePoints();
    setState(() {
      userPosition = widget.position;
    });
  }

  setListener() {
    socket.on("noTow", (data) {
      print("data");
    });

    socket.on("driverLocationUpdate", (data) {});

    socket.on("towAccept", (data) {
      print(data);
      setState(() {
        found = true;
        towTruck = LatLng(data['latitude'], data['longtitude']);
      });
    });
  }

  getDriver() {
    socket.emit("towRequest", {
      "firstName": widget.user.firstName,
      "lastName": widget.user.lastName,
      "userId": widget.user.id,
      "pickUpLocationLatitude": userPosition!.latitude,
      "pickUpLocationLongtitude": userPosition!.longitude
    });
  }

  initSocket() async {
    socket = IO.io("http://172.20.10.5:5000", {
      "transports": ['websocket'],
      "autoConnect": false
    });
    socket.connect();
    // socket!.emit("add", widget.user.id);
    socket.emit("add", {"userId": widget.user.id});
  }

  getCarImage() async {
    BitmapDescriptor customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/towTruck.png");
    setState(() {
      carImage = customMarkerIcon;
    });
  }

  void setTowPolyline(LatLng driver) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.apiKey,
      PointLatLng(driver.latitude, driver.longitude),
      PointLatLng(userPosition!.latitude, userPosition!.longitude),
    );

    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _markers.add(Marker(
            markerId: const MarkerId('sourcePin'),
            position: towTruck,
            icon: carImage));

        _markers.add(Marker(
          markerId: const MarkerId('destinationPin'),
          position: LatLng(userPosition!.latitude, userPosition!.longitude),
        ));

        _polylines.add(Polyline(
            width: 10,
            polylineId: const PolylineId('driver'),
            color: const Color(0xFF08A5CB),
            points: polylineCoordinates));
      });
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Constants.background,
        appBar: !found
            ? AppBar(
                elevation: 0,
                backgroundColor: Constants.background,
                title: const Text(
                  "Towing",
                ),
                foregroundColor: Colors.black,
                centerTitle: true,
              )
            : null,
        body: found ? map() : loadingUi(),
      ),
    );
  }

  map() {
    return Stack(children: [
      GoogleMap(
        polylines: _polylines,
        markers: _markers,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: LatLng(userPosition!.latitude, userPosition!.longitude),
            zoom: 15),
        onMapCreated: (controller) {
          _controller.complete(controller);
          setTowPolyline(towTruck);
        },
      ),
      Positioned(
          bottom: 0,
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Colors.white),
              child: const Center(
                child: Text(
                  "Help is on the way !!",
                  style: TextStyle(fontSize: 20),
                ),
              )))
    ]);
  }

  loadingUi() {
    return agreed ? animation(context) : firstPage(context);
  }

  SizedBox firstPage(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Image.asset("assets/images/needTow.png"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Broke down? Need a Towing-truck?",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    agreed = true;
                  });
                  animationController.forward();
                  getDriver();
                },
                child: const Text("Find a Tow-Truck"))
          ],
        ),
      ),
    );
  }

  animation(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: Tween<double>(begin: 0.5, end: 1.0)
                    .animate(CurvedAnimation(
                        parent: animationController, curve: Curves.easeIn))
                    .value,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: lottie.LottieBuilder.asset(
                      "assets/animations/towtruck.json"),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            "Finding nearest Towing Truck...",
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
