// To parse this JSON data, do
//
//     final participant = participantFromJson(jsonString);

import 'dart:convert';

Participant participantFromJson(String str) =>
    Participant.fromJson(json.decode(str));

String participantToJson(Participant data) => json.encode(data.toJson());

class Participant {
  int? id;
  Person? person;

  Participant({
    this.id,
    this.person,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json["id"],
        person: json["person"] == null ? null : Person.fromJson(json["person"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "person": person?.toJson(),
      };
}

class Person {
  int? id;
  String? email;
  String? firstName;
  String? lastName;
  String? phone;

  Person({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json["id"],
        email: json["email"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
      };
}
