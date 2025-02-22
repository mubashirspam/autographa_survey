import 'package:autographa_survey/model/survey_question_model.dart';
import 'package:flutter/material.dart';
import 'package:autographa_survey/model/survey_answer_model.dart';
import 'package:autographa_survey/provider/repository.dart';
import 'package:autographa_survey/provider/utils.dart';

class SurveyProvider extends ChangeNotifier {
  final Repository _repository = Repository();
  LoadingState _state = LoadingState.idle;
  bool _isSubmitting = false;
  List<SurveyQuestionModel> _surveyQuestionsList = [];
  String? _error;

  int _currentQuestionIndex = 0;

  // Maps to store answers
  final Map<String, String> _selectedAnswers = {};
  final Map<String, String> _textAnswers = {};

  // Getters
  LoadingState get state => _state;
  bool get isSubmitting => _isSubmitting;
  List<SurveyQuestionModel> get surveyQuestionsList => _surveyQuestionsList;
  String? get error => _error;
  bool get isLoading => _state == LoadingState.loading;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isLastQuestion =>
      _currentQuestionIndex == _surveyQuestionsList.length - 1;

  void nextQuestion() {
    if (_currentQuestionIndex < _surveyQuestionsList.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void setAnswer(String questionId, {String? optionId, String? text}) {
    if (optionId != null) {
      _selectedAnswers[questionId] = optionId;
    } else if (text != null) {
      _textAnswers[questionId] = text;
    }
    notifyListeners();
  }

  String? getSelectedAnswer(String questionId) => _selectedAnswers[questionId];
  String? getTextAnswer(String questionId) => _textAnswers[questionId];

  bool get canSubmit {
    for (var question in _surveyQuestionsList) {
      final questionId = question.questionId.toString();
      if (question.questionType == QuestionType.mcq) {
        if (!_selectedAnswers.containsKey(questionId)) {
          return false;
        }
      } else if (question.questionType == QuestionType.longAnswer) {
        if (!_textAnswers.containsKey(questionId) ||
            _textAnswers[questionId]?.isEmpty == true) {
          return false;
        }
      }
    }
    return true;
  }

  Future<bool> submitSurveyAnswers(String surveyId, String userId) async {
    _isSubmitting = true;
    notifyListeners();
    List<SurveyAnswer> answers = [];

    // Process MCQ answers
    _selectedAnswers.forEach((questionId, optionId) {
      answers.add(SurveyAnswer(
        questionId: questionId,
        answerOptionId: optionId,
      ));
    });

    // Process text answers
    _textAnswers.forEach((questionId, text) {
      answers.add(SurveyAnswer(
        questionId: questionId,
        text: text,
      ));
    });

    final request = SurveyAnswerRequest(
      surveyId: surveyId,
      userId: userId,
      answers: answers,
    );

    final response =
        await _repository.submitSurveyAnswers(request.toJsonString());

    if (response.success) {
      _isSubmitting = false;
      _selectedAnswers.clear();
      _currentQuestionIndex = 0;
      _textAnswers.clear();
      notifyListeners();
      return true;
    } else {
      _isSubmitting = false;
      _error = response.error;
      notifyListeners();
      return false;
    }
  }

  Future<List<SurveyQuestionModel>> fetchSurveyQuestions(
      String surveyId) async {
    try {
      _state = LoadingState.loading;
      _error = null;
      notifyListeners();

      final response = await _repository.fetchSurveyQuestions(surveyId);

      if (response.success && response.data != null) {
        _surveyQuestionsList = response.data!;
        _state = LoadingState.idle;
        return _surveyQuestionsList;
      } else {
        _error = response.error ?? 'Failed to fetch surveys';
        _state = LoadingState.error;
        throw Exception(_error);
      }
    } catch (e) {
      _error = 'Error processing survey data: ${e.toString()}';
      _state = LoadingState.error;
      notifyListeners();
      throw Exception(_error);
    } finally {
      notifyListeners();
    }
  }

  void resetError() {
    _error = null;
    _state = LoadingState.idle;
    notifyListeners();
  }
}
