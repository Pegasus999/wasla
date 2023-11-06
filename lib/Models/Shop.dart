class Shop {
  String id = '';
  String name = '';
  double latitude = 0;
  double longtitude = 0;
  String phoneNumber = '';
  ShopType? type;

  Shop(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longtitude,
      required this.phoneNumber,
      required this.type});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
        id: json["id"],
        name: json["name"],
        latitude: json["latitude"],
        longtitude: json['longtitude'],
        phoneNumber: json["phoneNumber"],
        type: json['type'] == "carwash"
            ? ShopType.carwash
            : json['type'] == "mechanic"
                ? ShopType.mechanic
                : ShopType.tollier);
  }
}

enum ShopType { carwash, mechanic, tollier }
