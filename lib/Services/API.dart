import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:wasla/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:wasla/Models/Cars.dart';
import 'package:wasla/Models/Shop.dart';
import 'package:wasla/Models/User.dart';

class API {
  static String url_base = "https://www.autoevolution.com/";
  static String base_url = "http://172.20.10.5:5000/api/";

  static Future<List<LatLng>> getNearbyDrivers(LatLng userPosition) async {
    return [LatLng(36.2955, 6.5334)];
  }

  static Future<LatLng> getNearstTow(LatLng userPosition) async {
    return LatLng(36.295837, 6.532003);
  }

  static Future getAddress(double lat, double lng) async {
    // Replace with your actual API key
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Constants.apiKey}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'OK') {
        return json['results'][0];
      } else {
        return 'Error: Unable to fetch address';
      }
    } else {
      return 'Error: HTTP request failed';
    }
  }

  static Future login(BuildContext context, String phoneNumber) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${base_url}auth/login');
      final body = jsonEncode({'phoneNumber': phoneNumber.trim()});
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        User? user = User.fromJson(json["user"]);

        return user;
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("No such user")));
      }
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error occured")));
    }
  }

  static Future getShops(int wilaya, ShopType type) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${base_url}shop/getShops');
      final body = jsonEncode(
          {'wilaya': wilaya, "type": type.toString().split(".").last});
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        List<Shop> shops = list.map((shop) => Shop.fromJson(shop)).toList();
        return shops;
      } else {
        return <Shop>[];
      }
    } catch (err) {
      print(err);

      return <Shop>[];
    }
  }

  static Future<bool> checkNumber(String number) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${base_url}auth/checkNumber');
      final body = jsonEncode({'phone_number': number});
      final response = await http.post(url, headers: headers, body: body);

      if (response.body == "Valid") {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      print(err);
      return false;
    }
  }

  static Future<List<Model>?> getCarModels(String brand) async {
    var response =
        await http.get(Uri.parse("https://api.auto-data.net/image-database"));
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      List<dom.Element> list = document.querySelectorAll("td > a");
      Map<String, String> brandsMap = {};
      List<Model> models = [];

      list.forEach((item) {
        if (!brandsMap.containsKey(item.text)) {
          brandsMap[item.text] = item.attributes["href"]!;
        }
      });

      // Extract the unique brand names from the hashmap
      List<String> brands = brandsMap.keys.toList();

      List<String> filtered = brands
          .where((item) => item.toLowerCase().contains(brand.toLowerCase()))
          .toList();

      filtered.forEach((element) {
        models.add(Model(name: element, url: brandsMap[element]!));
      });

      return models;
    }
    return [];
  }

  static Future<List<String>?> getCarGenerations(String url) async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      var containers = document.querySelectorAll('.years>h2>a>span');

      List<String> list = containers.map((e) => e.text).toList();

      return list;
    }
    return [];
  }

  static Future<String?> getCarImage(String url) async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);

      String src = document
          .getElementsByClassName("inCarList")[0]
          .attributes["src"]!
          .replaceFirst("_thumb", "");
      return "https://www.auto-data.net/" + src;
    }
    return "";
  }
}
