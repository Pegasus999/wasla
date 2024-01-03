import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wasla/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:wasla/Models/Cars.dart';
import 'package:wasla/Models/Shop.dart';
import 'package:wasla/Models/User.dart';

class API {
  static String url_base = "https://www.autoevolution.com/";
  // static String base_url = "https://waslaandk.onrender.com/api/";
  static String base_url = "http://192.168.1.2:5000/api/";

  static Future register(BuildContext context, String phoneNumber,
      String firstName, String lastName, int wilaya) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${base_url}auth/signUp');
      final body = jsonEncode({
        'phoneNumber': phoneNumber.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'wilaya': wilaya
      });
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        User? user = User.fromJson(json["user"]);

        return user;
      }
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error occured")));
    }
  }

  static Future getAddress(double lat, double lng) async {
    try {
      // Replace with your actual API key
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Constants.apiKey}';

      print(url);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['results'][0];
      }
      return {"error": "Error getting the address"};
    } catch (e) {
      print(e);
      return {"error": "Error getting the address"};
    }
  }

  static Future<User?> login(BuildContext context, String phoneNumber) async {
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
        return null;
      }
    } catch (err) {
      print(err);

      throw Exception("Error occured");
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

      for (var item in list) {
        if (!brandsMap.containsKey(item.text)) {
          brandsMap[item.text] = item.attributes["href"]!;
        }
      }

      // Extract the unique brand names from the hashmap
      List<String> brands = brandsMap.keys.toList();

      List<String> filtered = brands
          .where((item) => item.toLowerCase().contains(brand.toLowerCase()))
          .toList();

      for (var element in filtered) {
        models.add(Model(name: element, url: brandsMap[element]!));
      }

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
      return "https://www.auto-data.net/$src";
    }
    return "";
  }
}
