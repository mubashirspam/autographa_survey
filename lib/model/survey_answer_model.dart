import 'dart:convert';

class SurveyAnswerRequest {
  final String surveyId;
  final String userId;
  final List<SurveyAnswer> answers;

  SurveyAnswerRequest({
    required this.surveyId,
    required this.userId,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
        "surveyId": surveyId,
        "userId": userId,
        "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
      };

  String toJsonString() => json.encode(toJson());
}

class SurveyAnswer {
  final String questionId;
  final String? answerOptionId;
  final String? text;

  SurveyAnswer({
    required this.questionId,
    this.answerOptionId,
    this.text,
  });

  Map<String, dynamic> toJson() => {
        "questionId": questionId,
        "answerOptionId": answerOptionId ?? "",
        "text": text ?? "",
      };
}
