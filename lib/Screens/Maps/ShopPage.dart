import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wasla/Constants.dart';
import 'package:wasla/Models/Shop.dart';
import 'package:wasla/Services/API.dart';

class ShopPage extends StatefulWidget {
  const ShopPage(
      {super.key,
      required this.position,
      required this.type,
      required this.wilaya});
  final Position? position;
  final ShopType type;
  final int wilaya;
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  bool loading = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Shop? selected;
  final Set<Marker> _markers = <Marker>{};
  List<Shop> shops = [];

  @override
  void initState() {
    super.initState();
    getShops();
  }

  getShops() async {
    setState(() {
      loading = true;
    });
    List<Shop> list = await API.getShops(widget.wilaya, widget.type);
    setState(() {
      shops = list;
      if (list.isNotEmpty) {
        selected = list[0];
      }
      loading = false;
    });
  }

  showPinsOnMap() async {
    for (var shop in shops.asMap().entries) {
      setState(() {
        _markers.add(Marker(
          onTap: () {
            setState(() {
              selected = shop.value;
            });
          },
          markerId: MarkerId('driver${shop.key}'),
          position: LatLng(shop.value.latitude, shop.value.longtitude),
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
          child: !loading
              ? shops.isEmpty
                  ? const Center(
                      child: Text(
                          "Sorry there are no registered shops in you wilaya"),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        _map(),
                        selected != null
                            ? _bottomContrainer()
                            : Positioned(
                                bottom: 0,
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _markers.add(
                                          const Marker(
                                              markerId: MarkerId("value"),
                                              position:
                                                  LatLng(36.814652, 7.715008)),
                                        );
                                      });
                                    },
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      color: Colors.red,
                                    )),
                              )
                      ],
                    )
              : const Center(
                  child: CircularProgressIndicator(),
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
        'https://www.google.com/maps/dir/?api=1&destination=${selected!.latitude},${selected!.longtitude}';

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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(color: Constants.secondaryDarker),
            color: Constants.secondary,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                selected!.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(
                height: 25,
                color: Colors.transparent,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Constants.main,
                    child: const FaIcon(
                      FontAwesomeIcons.phone,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => openGoogleMaps(),
                    child: CircleAvatar(
                      backgroundColor: Constants.main,
                      radius: 30,
                      child: const FaIcon(
                        FontAwesomeIcons.route,
                        color: Colors.white,
                      ),
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
