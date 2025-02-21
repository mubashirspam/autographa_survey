// To parse this JSON data, do
//
//     final surveyQuestionModel = surveyQuestionModelFromJson(jsonString);

import 'dart:convert';

import '../provider/utils.dart';

List<SurveyQuestionModel> surveyQuestionModelFromJson(String str) => List<SurveyQuestionModel>.from(json.decode(str).map((x) => SurveyQuestionModel.fromJson(x)));

String surveyQuestionModelToJson(List<SurveyQuestionModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SurveyQuestionModel {
    int? questionId;
    String? questionText;
    int? surveyId;
    QuestionType? questionType;
    String? parentQuestionId;
    List<SurveyQuestionModel>? childQuestions;
    List<AnswerOption>? answerOptions;

    SurveyQuestionModel({
        this.questionId,
        this.questionText,
        this.surveyId,
        this.questionType,
        this.parentQuestionId,
        this.childQuestions,
        this.answerOptions,
    });

    factory SurveyQuestionModel.fromJson(Map<String, dynamic> json) => SurveyQuestionModel(
        questionId: json["questionId"],
        questionText: json["questionText"],
        surveyId: json["surveyId"],
        questionType: QuestionType.fromString(json["questionType"]),
        parentQuestionId: json["parentQuestionId"],
        childQuestions: json["childQuestions"] == null ? [] : List<SurveyQuestionModel>.from(json["childQuestions"]!.map((x) => SurveyQuestionModel.fromJson(x))),
        answerOptions: json["answerOptions"] == null ? [] : List<AnswerOption>.from(json["answerOptions"]!.map((x) => AnswerOption.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "questionId": questionId,
        "questionText": questionText,
        "surveyId": surveyId,
        "questionType": questionType?.value,
        "parentQuestionId": parentQuestionId,
        "childQuestions": childQuestions == null ? [] : List<dynamic>.from(childQuestions!.map((x) => x.toJson())),
        "answerOptions": answerOptions == null ? [] : List<dynamic>.from(answerOptions!.map((x) => x.toJson())),
    };
}

class AnswerOption {
    int? optionId;
    String? optionValue;

    AnswerOption({
        this.optionId,
        this.optionValue,
    });

    factory AnswerOption.fromJson(Map<String, dynamic> json) => AnswerOption(
        optionId: json["optionId"],
        optionValue: json["optionValue"],
    );

    Map<String, dynamic> toJson() => {
        "optionId": optionId,
        "optionValue": optionValue,
    };
}

