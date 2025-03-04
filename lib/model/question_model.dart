import 'answer_option_model.dart';
import 'survey_model.dart';

class Question {
  int? id;
  String? section;
  int? childOrder;
  int? surveyOrder;
  Survey? survey;
  QuestionType? questionType;
  ParentQuestion? parentQuestion;
  String? text;

  Question({
    this.id,
    this.section,
    this.childOrder,
    this.surveyOrder,
    this.survey,
    this.questionType,
    this.text,
    this.parentQuestion,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int?,
      text: json['text'] as String?,
      section: json['section'] as String?,
      childOrder: json['childOrder'] as int?,
      surveyOrder: json['surveyOrder'] as int?,
      survey: json['survey'] != null
          ? Survey.fromJson(json['survey'] as Map<String, dynamic>)
          : null,
      questionType: json['questionType'] != null
          ? QuestionType.fromJson(json['questionType'] as Map<String, dynamic>)
          : null,
      parentQuestion: json['parentQuestion'] != null
          ? ParentQuestion.fromJson(
              json['parentQuestion'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
      'text': text,
      'childOrder': childOrder,
      'surveyOrder': surveyOrder,
      'survey': survey?.toJson(),
      'questionType': questionType != null ? {'questionType': questionType!.toJson()} : null,
      'parentQuestion': parentQuestion?.toJson(),
    };
  }
}

class ParentQuestion {
  final int? id;
  final String? section;

  ParentQuestion({
    this.id,
    this.section,
  });

  factory ParentQuestion.fromJson(Map<String, dynamic> json) {
    return ParentQuestion(
      id: json['id'] as int?,
      section: json['section'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
    };
  }
}

// QuestionTypeModel class removed as we're using the QuestionType enum directly

class QuestionModel {
  int? id;
  int? surveyId;
  QuestionType? questionType;
  List<QuestionModel>? children;
  String? text;
  List<AnswerOption>? answerOptions;

  QuestionModel({
    this.id,
    this.surveyId,
    this.questionType,
    this.children,
    this.text,
    this.answerOptions,
  });
}

enum QuestionType {
  parentQuestion('ParentQuestion'),
  mcq('MCQ'),
  longAnswer('LongAnswer');

  final String value;
  const QuestionType(this.value);

  static QuestionType? fromString(String? value) {
    if (value == null) return null;
    return QuestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => QuestionType.longAnswer,
    );
  }

  static QuestionType? fromJson(Map<String, dynamic> json) {
    final typeStr = json['questionType'] as String?;
    return QuestionType.fromString(typeStr);
  }

  String toJson() => value;
}
