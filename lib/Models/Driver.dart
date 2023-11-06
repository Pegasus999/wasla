class Driver {
  String id = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  double latitude = 0;
  double longtitude = 0;
  String licensePlate = '';
  String carBrand = '';
  String carName = '';
  iDriver type = iDriver.taxi;

  Driver(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.phoneNumber,
      required this.latitude,
      required this.longtitude,
      required this.licensePlate,
      required this.carBrand,
      required this.carName});

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        latitude: json['latitude'],
        longtitude: json['longtitude'],
        carBrand: json['carBrand'],
        licensePlate: json['licensePlate'],
        phoneNumber: json["phoneNumber"],
        carName: json['carName']);
  }
}

enum iDriver { taxi, tow }
