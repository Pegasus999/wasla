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
import 'package:wasla/Services/API.dart';

class TaxiView extends StatefulWidget {
  TaxiView(
      {super.key,
      this.from,
      this.to,
      required this.user,
      required this.wilaya,
      this.trip});
  GeocodingResult? from;
  GeocodingResult? to;
  final User user;
  final Trip? trip;
  final int wilaya;
  @override
  State<TaxiView> createState() => _TaxiViewState();
}

class _TaxiViewState extends State<TaxiView>
    with SingleTickerProviderStateMixin {
  Position? userPosition;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  Set<Marker> _markers = <Marker>{};
  bool loading = true;
  bool requested = false;
  bool found = false;
  Completer<void> _delayCompleter = Completer<void>();

  int cost = 0;
  List<LatLng> drivers = [];
  Trip? trip;
  late BitmapDescriptor carImage;
  late IO.Socket socket;
  late AnimationController controller;
  late Animation<double> _animation;
  @override
  void dispose() {
    controller.dispose();
    socket.disconnect();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    initSocket();
    super.initState();
    getUserPosition();

    polylinePoints = PolylinePoints();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    // Define the bouncing animation using Tween
    _animation = Tween<double>(
      begin: 0,
      end: 6,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.bounceOut,
      ),
    );

    // Start the animation
    controller.repeat(reverse: true);
    setListener();
    if (widget.trip == null) {
      getCarImage();
      setRidePolylines();
    } else {
      if (mounted) {
        setState(() {
          trip = widget.trip;
          found = true;
          requested = true;
          loading = false;
        });
        getAddress();
      }
    }
  }

  getAddress() async {
    Map<String, dynamic> fromLoc = await API.getAddress(
        trip!.pickUpLocationLatitude, trip!.pickUpLocationLongtitude);
    Map<String, dynamic> toLoc = await API.getAddress(
        trip!.destinationLatitude, trip!.destinationLongtitude);
    print(fromLoc);
    print(toLoc);
    setState(() {
      widget.from = GeocodingResult.fromJson(fromLoc);
      widget.to = GeocodingResult.fromJson(toLoc);
    });
  }

  setListener() {
    socket.on("added", (data) {
      print("we connected");
    });

    socket.on("tripCreated", (data) {
      if (mounted) {
        print(data['trip']);
        Trip result = Trip.fromJson(data['trip']);
        setState(() {
          setState(() {
            trip = result;
          });
        });
      }
    });

    socket.on("error", (data) {
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
                    socket.connect();
                    Navigator.pop(context);
                  },
                  child: const Text("Retry"))
            ]),
      );
    });
    socket.on("rideAccept", (data) {
      if (mounted) {
        Trip result = Trip.fromJson(data['trip']);
        setState(() {
          trip = result;
          found = true;
        });
        if (!_delayCompleter.isCompleted) {
          _delayCompleter.complete();
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            loading = false;
          });
        });
        setDriverPolylines(
            LatLng(trip!.driver!.latitude, trip!.driver!.longtitude));
      }
    });
    socket.on("driverLocationUpdate", (data) {
      setState(() {
        trip!.driver = Driver.fromJson(data['driver']);
      });
      setDriverPolylines(
          LatLng(trip!.driver!.latitude, trip!.driver!.longtitude));
    });

    socket.on('rideEnd', (data) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Ride ended"),
            content: SizedBox(
              height: 100,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Ride has Ended"),
                    const SizedBox(height: 40),
                    Text("Your total is : ${trip!.cost} DA")
                  ]),
            ),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        user: widget.user,
                      ),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ).then(
          (value) {
            if (value == null) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    user: widget.user,
                  ),
                ),
                (route) => false,
              );
            }
          },
        );
      }
    });

    socket.on("noRides", (data) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("No Drivers"),
            content: SizedBox(
              height: 200,
              child: Center(child: Text(data)),
            ),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ).then((value) => Navigator.of(context).pop());
      }
    });
    socket.on('rideCancel', (data) {
      if (mounted && data['byWho'] != widget.user.id) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Ride Cancelled"),
            content: const SizedBox(
              height: 50,
              child: Text("Sadly, your driver has cancelled your ride"),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          user: widget.user,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text("OK"))
            ],
          ),
        ).then((value) => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  user: widget.user,
                ),
              ),
              (route) => false,
            ));
      }
    });
  }

  cancelRide() {
    if (trip != null) {
      socket.emit("rideCancel", {"tripId": trip!.id, "userId": widget.user.id});
    }
  }

  initSocket() async {
    socket = IO.io("https://wasla.online", {
      "transports": ['websocket'],
      "autoConnect": false
    });

    socket.connect();

    socket.emit("add", {"userId": widget.user.id});
  }

  int calculateCost(List<LatLng> polylineCoordinates) {
    double totalDistance = 0.0;

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      final LatLng p1 = polylineCoordinates[i];
      final LatLng p2 = polylineCoordinates[i + 1];
      final distance = Geolocator.distanceBetween(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      );
      totalDistance += distance;
    }
    double distanceInKm = totalDistance / 1000;
    double distanceXcost = distanceInKm * 35;
    print(distanceXcost.toInt());
    return distanceXcost.toInt();
  }

  getDriver() async {
    setState(() {
      requested = true;
    });
    _delayCompleter = Completer<void>();
    // TODO: Change this delay
    Future.delayed(
      const Duration(minutes: 3),
      () {
        if (!found && mounted && !_delayCompleter.isCompleted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("No Drivers"),
              content: const SizedBox(
                height: 60,
                child: Center(
                    child: Text("Sadly, No driver has picked up your order")),
              ),
              actions: [
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ).then((value) => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    user: widget.user,
                  ),
                ),
                (route) => false,
              ));
        }
      },
    );
    try {
      socket.emit("rideRequest", {
        "wilaya": widget.wilaya,
        "userId": widget.user.id,
        "cost": cost,
        "destinationLatitude": widget.to!.geometry.location.lat,
        "destinationLongtitude": widget.to!.geometry.location.lng,
        "pickUpLocationLatitude": widget.from!.geometry.location.lat,
        "pickUpLocationLongtitude": widget.from!.geometry.location.lng
      });
    } catch (e) {
      print(e);
    }
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
    if (mounted) {
      setState(() {
        userPosition = location;
      });
    }
  }

  void setRidePolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.apiKey,
      PointLatLng(widget.from!.geometry.location.lat,
          widget.from!.geometry.location.lng),
      PointLatLng(
          widget.to!.geometry.location.lat, widget.to!.geometry.location.lng),
    );

    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      int amount = calculateCost(polylineCoordinates);
      if (mounted) {
        setState(() {
          cost = amount;
          _polylines.add(Polyline(
              width: 10,
              polylineId: const PolylineId('polyLine'),
              color: const Color(0xFF08A5CB),
              points: polylineCoordinates));
        });
      }
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
      PointLatLng(widget.from!.geometry.location.lat,
          widget.from!.geometry.location.lng),
    );

    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _markers.addAll([
          Marker(
              markerId: const MarkerId('driver'),
              position: driver,
              icon: carImage),
          Marker(
            markerId: const MarkerId('destinationPin'),
            position: LatLng(widget.from!.geometry.location.lat,
                widget.from!.geometry.location.lng),
          )
        ]);
        _polylines.add(Polyline(
            width: 10,
            polylineId: const PolylineId('driver'),
            color: const Color(0xFF08A5CB),
            points: polylineCoordinates));
      });
    }
  }

  void showPinsOnMap() {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('sourcePin'),
        position: LatLng(widget.from!.geometry.location.lat,
            widget.from!.geometry.location.lng),
      ));

      _markers.add(Marker(
        markerId: const MarkerId('destinationPin'),
        position: LatLng(
            widget.to!.geometry.location.lat, widget.to!.geometry.location.lng),
      ));
    });
  }

  // giyrufuohfouy
  Future<bool> showCancelDialog() async {
    // showDialog implementation...

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const SizedBox(
          height: 70,
          child:
              Center(child: Text("Are you sure you want to cancel this ride?")),
        ),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              cancelRide();
              setState(() {
                trip = null;
                requested = false;
                found = false;
              });
              if (!_delayCompleter.isCompleted) {
                _delayCompleter.complete();
              }
              resetMap();
              setRidePolylines();

              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (requested) {
            return showCancelDialog();
          } else {
            return false;
          }
        },
        child: Scaffold(
            floatingActionButton: Container(
              margin: const EdgeInsets.only(top: 20),
              child: FloatingActionButton(
                  onPressed: () async {
                    if (requested) {
                      bool back = await showCancelDialog();
                      if (back) {
                        Navigator.pop(context);
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const FaIcon(FontAwesomeIcons.xmark)),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            body: trip != null && trip!.driver != null
                ? DraggableBottomSheet(
                    minExtent: 200,
                    useSafeArea: false,
                    curve: Curves.easeIn,
                    previewWidget: bottomContainer(context),
                    expandedWidget: expandedContainer(context),
                    backgroundWidget: map(),
                    maxExtent: MediaQuery.of(context).size.height * 0.8,
                    onDragging: (pos) {},
                  )
                : Stack(children: [
                    Positioned(
                      key: const Key(
                          'mapPositioned'), // Add a key to the Positioned widget
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: map(),
                    ),
                    Positioned(
                      key: const Key(
                          'bottomContainerPositioned'), // Add a key to the Positioned widget
                      bottom: 0,
                      child: _bottomContainer(context),
                    ),
                  ])),
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
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
              if (widget.trip == null) {
                showPinsOnMap();
              }
            },
          )
        : Constants.loading;
  }

  _bottomContainer(BuildContext context) {
    return requested
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: Colors.white),
            child: lookingForDriver())
        : Container(
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
                      const Text(
                        "Price : ",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "${cost == 0 ? "Calculating..." : '$cost Da'} ",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if (userPosition != null && cost != 0) {
                      getDriver();
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor: cost == 0
                          ? MaterialStatePropertyAll(
                              Colors.blue.withOpacity(0.4))
                          : const MaterialStatePropertyAll(Colors.blue),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)))),
                  child: const Text("Find a Driver"),
                )
              ],
            ),
          );
  }

  bottomContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 140,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Colors.white),
      child: driverPreview(),
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
            AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                      offset: Offset(0, _animation.value),
                      child: FaIcon(FontAwesomeIcons.arrowUp,
                          color: Colors.blueGrey[200]));
                }),
            const SizedBox(width: 15),
            const Text(
              "Your Driver",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 15),
            AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                      offset: Offset(0, _animation.value),
                      child: FaIcon(FontAwesomeIcons.arrowUp,
                          color: Colors.blueGrey[200]));
                }),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
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
              child: const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.green,
                child: Center(
                    child: FaIcon(
                  FontAwesomeIcons.phone,
                  color: Colors.white,
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
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
                const CircleAvatar(
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
                        "${trip!.driver != null ? trip!.driver!.firstName : ""} ${trip!.driver != null ? trip!.driver!.lastName : ""}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "0${trip!.driver != null ? trip!.driver!.phoneNumber : ""}",
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const CircleAvatar(
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
              "${trip!.driver != null ? trip!.driver!.carBrand : ""} ${trip!.driver != null ? trip!.driver!.carName : ""}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              trip!.driver != null ? trip!.driver!.licensePlate : "",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            const Text(
              "Ride",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text(
              widget.to != null ? widget.to!.formattedAddress! : "",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            const FaIcon(FontAwesomeIcons.arrowDown),
            const SizedBox(height: 15),
            Text(
              widget.to != null ? widget.to!.formattedAddress! : "",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              "Price",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              "${trip!.driver != null ? trip!.cost : ""} DA",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  lookingForDriver() {
    return found
        ? const Center(
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
