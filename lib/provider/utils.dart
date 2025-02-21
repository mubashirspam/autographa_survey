enum LoadingState { idle, loading, error }

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

  String toJson() => value;
}