import 'package:flutter/material.dart';

import 'package:autographa_survey/provider/repository.dart';
import '../model/model.dart';
import '../utils/utlis.dart';

class SurveyProvider extends ChangeNotifier {
  // ==================== PRIVATE VARIABLES ====================
  final _repository = Repository();

  // API Response states
  ApiResponse<List<QuestionModel>> _questionResponse = ApiResponse.idle();
  ApiResponse<List<AnswerOption>> _allOptionsResponse = ApiResponse.idle();
  ApiResponse<List<AnswerOption>> _optionsByQuestionResponse =
      ApiResponse.idle();
  ApiResponse<List<ResponseAnswer>> _answerResponse = ApiResponse.idle();
  ApiResponse<ResponseAnswer> _submitAnswerResponse = ApiResponse.idle();

  // Navigation state
  int _currentQuestionIndex = 0;

  List<AnswerModel> answerList = [];

  // ==================== GETTERS ====================

  // Question getters
  ApiResponse<List<QuestionModel>> get questionResponse => _questionResponse;
  List<QuestionModel> get questionList => _questionResponse.data ?? [];

  // Answer option getters
  List<AnswerOption> get answerOptions => _allOptionsResponse.data ?? [];
  List<AnswerOption> get optionsByQuestion =>
      _optionsByQuestionResponse.data ?? [];

  // Response getters
  ApiResponse<ResponseAnswer> get submitAnswerResponse => _submitAnswerResponse;
  ApiResponse<List<ResponseAnswer>> get answerResponse => _answerResponse;

  // Navigation getters
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isLastQuestion => _currentQuestionIndex == questionList.length - 1;

  // ==================== USER ANSWER METHODS ====================

  String? getSelectedAnswer(String questionId) {
    try {
      return answerList
          .firstWhere((element) => element.questionId == int.parse(questionId))
          .optionId
          ?.toString();
    } catch (e) {
      return null;
    }
  }

  String? getTextAnswer(String questionId) {
    try {
      return answerList
          .firstWhere((element) => element.questionId == int.parse(questionId))
          .answer;
    } catch (e) {
      return null;
    }
  }

  void setAnswer(String questionId,
      {String? optionId, String? text, int? id, bool isChecked = false}) {
    final existingAnswerIndex = answerList
        .indexWhere((element) => element.questionId == int.parse(questionId));

    if (existingAnswerIndex != -1) {
      if (optionId != null) {
        answerList[existingAnswerIndex] =
            answerList[existingAnswerIndex].copyWith(
          id: id,
          optionId: int.parse(optionId),
          answer: null,
          isChecked: isChecked,
        );
      } else if (text != null) {
        answerList[existingAnswerIndex] =
            answerList[existingAnswerIndex].copyWith(
          id: id,
          answer: text,
          optionId: null,
          isChecked: isChecked,
        );
      }
    } else {
      if (optionId != null) {
        answerList.add(
          AnswerModel(
            id: id,
            questionId: int.parse(questionId),
            optionId: int.parse(optionId),
            isChecked: isChecked,
          ),
        );
      } else if (text != null) {
        answerList.add(
          AnswerModel(
            id: id,
            questionId: int.parse(questionId),
            answer: text,
            isChecked: isChecked,
          ),
        );
      }
    }

    notifyListeners();
  }

  // ==================== NAVIGATION METHODS ====================

  /// Move to the next question
  void nextQuestion() {
    if (_currentQuestionIndex < questionList.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Move to the previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // ==================== VALIDATION METHODS ====================
  bool get canSubmit {
    final List<QuestionModel> allQuestionsToValidate =
        questionList.expand<QuestionModel>((question) {
      if (question.questionType == QuestionType.parentQuestion) {
        return question.children ?? [];
      }
      return [question];
    }).toList();

    return allQuestionsToValidate.every((question) {
      final answer = answerList.firstWhere(
        (ans) => ans.questionId == question.id,
        orElse: () => AnswerModel(),
      );

      return switch (question.questionType) {
        QuestionType.mcq => answer.optionId != null,
        QuestionType.longAnswer => answer.answer?.isNotEmpty ?? false,
        QuestionType.parentQuestion => true,
        null => false,
      };
    });
  }

  Future<void> loadQuestionsScreen(Response response, {required bool isRefresh}) async {
    if (_questionResponse.isLoading || _questionResponse.isSuccess) {
      return;
    }
    _questionResponse = ApiResponse.loading();
    notifyListeners();
    await fetchResponseAnswerByResponseId(response.id.toString());
    await fetchAllAnswerOptions();
    await fetchQuestionBySurvey(response.survey!.id.toString());
  }

  // ==================== API METHODS ====================

  /// Fetch questions for a specific survey
  Future<void> fetchQuestionBySurvey(String surveyId) async {
    _questionResponse = ApiResponse.loading();
    notifyListeners();

    final data = await _repository.fetchQuestionBySurvey(surveyId);
    if (data.isSuccess) {
      final convertedData = _convertQuestionsToModel(data.data ?? []);
      _questionResponse = ApiResponse.success(convertedData);
    } else {
      _questionResponse = ApiResponse.error(data.error ?? 'Unknown error');
    }
    notifyListeners();
  }

  // ----- Answer Option API Methods -----

  /// Fetch all answer options
  Future<void> fetchAllAnswerOptions() async {
    _allOptionsResponse = ApiResponse.loading();
    notifyListeners();
    _allOptionsResponse = await _repository.getAllAnswerOptions();
    notifyListeners();
  }

  /// Fetch answer options for a specific question
  Future<void> fetchAnswerOptionByQuestion(String questionId) async {
    _optionsByQuestionResponse = ApiResponse.loading();
    notifyListeners();
    _optionsByQuestionResponse =
        await _repository.getAllAnswerOptionsByQuestion(questionId);
    notifyListeners();
  }

  // ----- Response Answer API Methods -----

  Future<void> submitSurveyAnswers(Response response) async {
    if (!canSubmit ||
        answerList.isEmpty ||
        response.id == null ||
        _submitAnswerResponse.isLoading) return;

    _submitAnswerResponse = ApiResponse.loading();
    notifyListeners();

    bool hasError = false;
    String errorMessage = '';

    for (var element in answerList) {
      if (element.questionId == null || !element.isChecked) continue;

      final data = ResponseAnswer(
        id: element.id,
        question: Question(id: element.questionId),
        response: response,
        answerOption: element.optionId != null
            ? AnswerOption(id: element.optionId)
            : null,
        answerText: element.answer,
      );

      final result = element.id != null
          ? await _repository.updateSurveyAnswers(data, element.id!)
          : await _repository.submitSurveyAnswers(data);

      if (!result.isSuccess) {
        hasError = true;
        errorMessage = result.error ?? 'Unknown error';
        break;
      }
    }

    if (hasError) {
      _submitAnswerResponse = ApiResponse.error(errorMessage);
    } else {
      _submitAnswerResponse = ApiResponse.success(ResponseAnswer());
      _questionResponse = ApiResponse.idle();
      _answerResponse = ApiResponse.idle();
      _allOptionsResponse = ApiResponse.idle();
      _optionsByQuestionResponse = ApiResponse.idle();
      questionList.clear();
      answerList.clear();
    }

    notifyListeners();
  }

  /// Fetch response answers for a specific response
  Future<void> fetchResponseAnswerByResponseId(String id) async {
    _answerResponse = ApiResponse.loading();
    notifyListeners();
    _answerResponse = await _repository.fetchResponseAnswerByResponseId(id);
    if (_answerResponse.isSuccess && _answerResponse.data?.isNotEmpty == true) {
      _processAnswer(_answerResponse.data!);
    }
    notifyListeners();
  }

  // ==================== HELPER METHODS ====================

  void _processAnswer(List<ResponseAnswer> answers) {
    answerList.clear();
    for (ResponseAnswer item in answers) {
      if (item.question == null) continue;
      if (item.answerOption != null) {
        setAnswer(
          item.question!.id.toString(),
          optionId: item.answerOption!.id.toString(),
          id: item.id,
        );
      } else if (item.answerText != null) {
        setAnswer(
          item.question!.id.toString(),
          text: item.answerText,
          id: item.id,
        );
      }
    }
  }

  List<QuestionModel> _convertQuestionsToModel(List<Question> questions) {
    // Create map of question models in one pass
    final questionMap = Map.fromEntries(
      questions.map((q) => MapEntry(
          q.id ?? 0,
          QuestionModel(
            id: q.id,
            surveyId: q.survey?.id,
            questionType: q.questionType,
            text: q.text,
            answerOptions: q.questionType == QuestionType.mcq && q.id != null
                ? (answerOptions
                    .where((opt) => opt.question?.id == q.id)
                    .toList()
                  ..ifEmpty(() {
                    fetchAnswerOptionByQuestion(q.id.toString());
                    return [];
                  }))
                : null,
            children: [],
          ))),
    );

    // Link children to parents and get root questions
    questions.where((q) => q.parentQuestion != null).forEach((q) {
      if (q.id != null && questionMap[q.parentQuestion!.id] != null) {
        questionMap[q.parentQuestion!.id]!.children!.add(questionMap[q.id!]!);
      }
    });

    return questionMap.values
        .where((q) =>
            questions
                .firstWhere((question) => question.id == q.id)
                .parentQuestion ==
            null)
        .toList();
  }
}

// Add this extension for the ifEmpty functionality
extension ListExtension<T> on List<T> {
  List<T> ifEmpty(Function() action) {
    if (isEmpty) {
      action();
    }
    return this;
  }
}
