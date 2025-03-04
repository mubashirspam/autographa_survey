import 'model.dart';

class Response {
  int? id;
  Survey? survey;
  Participant? participant;

  Response({
    this.id,
    this.survey,
    this.participant,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        id: json["id"],
        survey: json["survey"] == null ? null : Survey.fromJson(json["survey"]),
        participant: json["participant"] == null
            ? null
            : Participant.fromJson(json["participant"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "survey": survey?.toJson(),
        "participant": participant?.toJson(),
      };
}
