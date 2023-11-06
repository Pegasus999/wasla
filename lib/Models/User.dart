class User {
  String id = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';

  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.phoneNumber});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        phoneNumber: json['phoneNumber']);
  }

  toJson() {
    return {
      "id": id,
      "firstName": firstName,
      "lastName": lastName,
      "phoneNumber": phoneNumber,
    };
  }
}
