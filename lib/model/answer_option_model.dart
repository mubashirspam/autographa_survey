import 'question_model.dart';

class AnswerOption {
  final int? id;
  final String? optionValue;
  final int? sequence;
  final Question? question;
  final QuestionType? questionType;

  AnswerOption({
    this.id,
    this.optionValue,
    this.sequence,
    this.question,
    this.questionType,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      id: json['id'] as int?,
      optionValue: json['optionValue'] as String?,
      sequence: json['sequence'] as int?,
      question: json['question'] != null
          ? Question.fromJson(json['question'] as Map<String, dynamic>)
          : null,
      questionType: json['questionType'] != null
          ? QuestionType.fromJson(json['questionType'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'optionValue': optionValue,
      'sequence': sequence,
      'question': question?.toJson(),
      'questionType': questionType != null ? {'questionType': questionType!.toJson()} : null,
    };
  }
}
