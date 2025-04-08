// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  int? id;
  String? username;
  String? password;
  String? email;
  String? firstName;
  String? lastName;
  String? token;

  User({
    this.id,
    this.username,
    this.password,
    this.email,
    this.firstName,
    this.lastName,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        password: json["password"],
        email: json["email"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "password": password,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "token": token,
      };
}
