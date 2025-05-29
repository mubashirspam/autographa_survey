

import 'model.dart';

class Response {
    int? id;
    String? linkType;
    String? linkComment;
    int? linkId;
    Survey? survey;
    Participant? participant;

    Response({
        this.id,
        this.linkType,
        this.linkId,
        this.survey,
        this.participant,
        this.linkComment,
    });

    factory Response.fromJson(Map<String, dynamic> json) => Response(
        id: json["id"],
        linkType: json["linkType"],
        linkComment: json["linkcomment"],
        linkId: json["linkId"],
        survey: json["survey"] == null ? null : Survey.fromJson(json["survey"]),
        participant: json["participant"] == null ? null : Participant.fromJson(json["participant"]),
    );

    Map<String, dynamic> toJson() {
        // Create a safe map that handles null values
        final Map<String, dynamic> json = {
            "id": id,
            "linkType": linkType,
            "linkcomment": linkComment,
            "linkId": linkId,
        };
        
        // Only add survey and participant if they're not null
        if (survey != null) {
            try {
                json["survey"] = survey!.toJson();
            } catch (e) {
                // If toJson fails, add a placeholder instead of null
                json["survey"] = {};
            }
        }
        
        if (participant != null) {
            try {
                json["participant"] = participant!.toJson();
            } catch (e) {
                // If toJson fails, add a placeholder instead of null
                json["participant"] = {};
            }
        }
        
        return json;
    }
}

