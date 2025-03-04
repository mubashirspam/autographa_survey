class AnswerModel {
  final int? id;
  final int? questionId;
  final int? optionId;
  final String? answer;
  final bool isChecked;

  AnswerModel({
    this.id,
    this.questionId,
    this.optionId,
    this.answer,
    this.isChecked = false,
  });

  AnswerModel copyWith({
    int? id,
    int? questionId,
    int? optionId,
    String? answer,
    bool? isChecked,
  }) {
    return AnswerModel(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      optionId: optionId ?? this.optionId,
      answer: answer ?? this.answer,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  String toString() {
    return 'AnswerModel(id: $id, questionId: $questionId, optionId: $optionId, answer: $answer, isChecked: $isChecked)';
  }
}
