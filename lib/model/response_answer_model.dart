import 'model.dart';

class ResponseAnswer {
  int? id;
  String? answerText;
  Question? question;
  AnswerOption? answerOption;
  Response? response;

  ResponseAnswer({
    this.id,
    this.answerText,
    this.question,
    this.answerOption,
    this.response,
  });

  factory ResponseAnswer.fromJson(Map<String, dynamic> json) => ResponseAnswer(
        id: json["id"],
        answerText: json["answerText"],
        question: json["question"] == null
            ? null
            : Question.fromJson(json["question"]),
        answerOption: json["answerOption"] == null
            ? null
            : AnswerOption.fromJson(json["answerOption"]),
        response: json["response"] == null
            ? null
            : Response.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "answerText": answerText,
        "question": question?.toJson(),
        "answerOption": answerOption,
        "response": response?.toJson(),
      };
}
