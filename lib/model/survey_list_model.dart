// To parse this JSON data, do
//
//     final surveyList = surveyListFromJson(jsonString);

import 'dart:convert';

List<SurveyList> surveyListFromJson(String str) => List<SurveyList>.from(json.decode(str).map((x) => SurveyList.fromJson(x)));

String surveyListToJson(List<SurveyList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SurveyList {
  String primaryKey;
  DateTime creationTimestamp;
  String createdBy;
  DateTime modificationTimestamp;
  String modifiedBy;
  int id;
  String surveyName;

  SurveyList({
    required this.primaryKey,
    required this.creationTimestamp,
    required this.createdBy,
    required this.modificationTimestamp,
    required this.modifiedBy,
    required this.id,
    required this.surveyName,
  });

  factory SurveyList.fromJson(Map<String, dynamic> json) => SurveyList(
    primaryKey: json["PrimaryKey"],
    creationTimestamp: DateTime.parse(json["CreationTimestamp"]),
    createdBy: json["CreatedBy"],
    modificationTimestamp: DateTime.parse(json["ModificationTimestamp"]),
    modifiedBy: json["ModifiedBy"],
    id: json["id"],
    surveyName: json["surveyName"],
  );

  Map<String, dynamic> toJson() => {
    "PrimaryKey": primaryKey,
    "CreationTimestamp": creationTimestamp.toIso8601String(),
    "CreatedBy": createdBy,
    "ModificationTimestamp": modificationTimestamp.toIso8601String(),
    "ModifiedBy": modifiedBy,
    "id": id,
    "surveyName": surveyName,
  };
}
