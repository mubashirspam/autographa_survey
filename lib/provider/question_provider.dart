import 'dart:developer';
import 'package:flutter/material.dart';
import '../data/survey_answer_local_storage.dart';
import '../model/model.dart';
import '../repository/question_repository.dart';
import '../provider/answer_option_provider.dart';
import '../repository/survey_answer_repository.dart';
import '../utils/utlis.dart';

class QuestionProvider extends ChangeNotifier {
  static final QuestionProvider _instance = QuestionProvider._internal();
  factory QuestionProvider() => _instance;
  QuestionProvider._internal();
  // ==================== PRIVATE VARIABLES ====================
  final _questionRepository = QuestionRepository();
  final _surveyAnswerRepository = SurveyAnswerRepository();
  final _answerOptionProvider = AnswerOptionProvider();

  // API Response states
  ApiResponse<List<QuestionModel>> _questionResponse = ApiResponse.idle();
  ApiResponse<Question> _singleQuestionResponse = ApiResponse.idle();

  ApiResponse<List<ResponseAnswer>> _answersResponse = ApiResponse.idle();
  ApiResponse<ResponseAnswer> _submitAnswerResponse = ApiResponse.idle();
  ApiResponse<ResponseAnswer> _updateAnswerResponse = ApiResponse.idle();

  // Local state
  List<QuestionModel> questionList = [];
  List<AnswerModel> answerList = [];
  int _currentQuestionIndex = 0;
  bool _isSyncing = false;
  String? _currentResponseId;

  // ==================== GETTERS ====================

  // Response getters
  ApiResponse<List<QuestionModel>> get questionResponse => _questionResponse;
  ApiResponse<Question> get singleQuestionResponse => _singleQuestionResponse;

  ApiResponse<List<ResponseAnswer>> get answersResponse => _answersResponse;
  ApiResponse<ResponseAnswer> get submitAnswerResponse => _submitAnswerResponse;
  ApiResponse<ResponseAnswer> get updateAnswerResponse => _updateAnswerResponse;

  // State getters
  int get currentQuestionIndex => _currentQuestionIndex;
  QuestionModel? get currentQuestion =>
      questionList.isNotEmpty && _currentQuestionIndex < questionList.length
          ? questionList[_currentQuestionIndex]
          : null;

  bool get hasQuestions => questionList.isNotEmpty;
  int get totalQuestions => questionList.length;

  // Navigation getters
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isLastQuestion => _currentQuestionIndex == questionList.length - 1;

  // ==================== PUBLIC METHODS ====================

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

  /// Load questions screen with all required data
  Future<void> loadQuestionsScreen(String responseId, String surveyId) async {
    if (_questionResponse.isLoading) {
      return;
    }

    _questionResponse = ApiResponse.loading();
    notifyListeners();

    // Fetch all answer options
    await _answerOptionProvider.fetchAllAnswerOptions();
    log(" answer Option completed");
    // Fetch answers for this response
    await fetchAnswersByResponseId(responseId);
    log(" Response completed");
    // Fetch questions for this survey
    await fetchQuestionBySurvey(surveyId);
    log("Question completed");
  }

  /// Fetch questions for a specific survey
  Future<void> fetchQuestionBySurvey(String surveyId) async {
    _questionResponse = ApiResponse.loading();
    notifyListeners();
    log("surveyId: $surveyId");
    try {
      // Listen to the stream of responses from the repository
      _questionRepository.fetchQuestionBySurvey(surveyId).listen(
        (response) {
          log('Received question response update');
          if (response.isSuccess && response.data != null) {
            final convertedData = _convertQuestionsToModel(response.data!);
            questionList = convertedData;
            _questionResponse =
                ApiResponse.success(convertedData, message: response.error);
            // Only reset the index if this is the first time we're getting data
            if (_currentQuestionIndex >= convertedData.length) {
              _currentQuestionIndex = 0;
            }
          } else {
            _questionResponse =
                ApiResponse.error(response.error ?? 'Unknown error');
          }
          notifyListeners();
        },
        onError: (e) {
          log('Stream error: $e');
          _questionResponse =
              ApiResponse.error('Failed to fetch questions: $e');
          notifyListeners();
        },
        onDone: () {
          log('Question response stream completed');
        },
      );
    } catch (e) {
      log('Error setting up question stream: $e');
      _questionResponse = ApiResponse.error('Failed to fetch questions: $e');
      notifyListeners();
    }
  }

  /// Get a specific question by ID
  Future<void> getQuestionById(int questionId) async {
    _singleQuestionResponse = ApiResponse.loading();
    notifyListeners();

    _singleQuestionResponse =
        await _questionRepository.getQuestionById(questionId);
    notifyListeners();
  }

  /// Clear cached questions for a specific survey
  Future<void> clearCacheBySurvey(String surveyId) async {
    await _questionRepository.clearCacheBySurvey(surveyId);

    // If this is the current survey, refresh questions
    if (questionList.isNotEmpty &&
        questionList[0].surveyId.toString() == surveyId) {
      await fetchQuestionBySurvey(surveyId);
    }
  }

  /// Clear all cached questions
  Future<void> clearCache() async {
    await _questionRepository.clearCache();
    reset();
  }

  /// Reset the provider state
  void reset() {
    _questionResponse = ApiResponse.idle();
    _singleQuestionResponse = ApiResponse.idle();

    questionList.clear();
    _currentQuestionIndex = 0;
    notifyListeners();
  }

  // ==================== HELPER METHODS ====================

  /// Convert Question objects to QuestionModel objects
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
                ? _answerOptionProvider.getOptionsForQuestion(q.id!)
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

  // Validation getters
  bool get canSubmit {
    log("questionList: ${questionList.length}");
    if (questionList.isEmpty) return false;

    final allQuestionsToValidate = questionList.expand((question) {
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

      final value = switch (question.questionType) {
        QuestionType.mcq => answer.optionId != null,
        QuestionType.longAnswer => answer.answer?.isNotEmpty ?? false,
        QuestionType.parentQuestion => true,
        null => true,
        _ => false,
      };

      return value;
    });
  }

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

  // ==================== PUBLIC METHODS ====================

  Future<void> fetchAnswersByResponseId(String responseId) async {
    _currentResponseId = responseId;
    _answersResponse = ApiResponse.loading();
    notifyListeners();

    // Listen to the stream of responses
    await for (final response in _surveyAnswerRepository
        .fetchResponseAnswerByResponseId(responseId)) {
      _answersResponse = response;
      _processAnswers();
      notifyListeners();
    }
  }

  /// Submit a new answer
  Future<ApiResponse<ResponseAnswer>> submitAnswer(
      ResponseAnswer answer) async {
    // TODO: Implement submitAnswer

    // if (_submitAnswerResponse.isLoading) {
    //   log('Already submitting answer********');
    //   return ApiResponse.loading();
    // }

    _submitAnswerResponse = ApiResponse.loading();
    notifyListeners();

    final result = await _surveyAnswerRepository.submitSurveyAnswers(answer);
    _submitAnswerResponse = result;

    // If successful, refresh the answers list
    if (result.isSuccess && _currentResponseId != null) {
      await fetchAnswersByResponseId(_currentResponseId!);
    }

    notifyListeners();
    return result;
  }

  /// Update an existing answer
  Future<ApiResponse<ResponseAnswer>> updateAnswer(
      ResponseAnswer answer, int id) async {
    _updateAnswerResponse = ApiResponse.loading();
    notifyListeners();

    final result =
        await _surveyAnswerRepository.updateSurveyAnswers(answer, id);
    _updateAnswerResponse = result;

    // If successful, refresh the answers list
    if (result.isSuccess && _currentResponseId != null) {
      await fetchAnswersByResponseId(_currentResponseId!);
    }

    notifyListeners();
    return result;
  }

  /// Submit multiple answers at once
  Future<bool> submitMultipleAnswers(List<ResponseAnswer> answersList,
      {BuildContext? context}) async {
    for (final answer in answersList) {
      log('Submitting answer:======== ${answer.response?.participant?.id}');
    }
    if (answersList.isEmpty) return true;

    bool hasError = false;

    for (final answer in answersList) {
      final result = answer.id != null
          ? await updateAnswer(answer, answer.id!)
          : await submitAnswer(answer);

      if (!result.isSuccess) {
        hasError = true;
      }
    }

    return !hasError;
  }

  /// Submit survey answers for a response
  Future<void> submitSurveyAnswers(int responseId) async {
    log('Submitting survey answers for response $responseId');
    _submitAnswerResponse = ApiResponse.loading();
    notifyListeners();

    // Convert answerList to ResponseAnswer objects
    final answersToSubmit = <ResponseAnswer>[];
    for (final answer in answerList) {
      final question = Question(id: answer.questionId);

      ResponseAnswer responseAnswer;
      if (answer.optionId != null) {
        // For MCQ questions
        final answerOption = AnswerOption(id: answer.optionId);
        responseAnswer = ResponseAnswer(
          id: answer.id,
          response: Response(id: responseId),
          question: question,
          answerOption: answerOption,
        );
      } else if (answer.answer != null && answer.answer!.isNotEmpty) {
        // For text answers
        responseAnswer = ResponseAnswer(
          id: answer.id,
          response: Response(id: responseId),
          question: question,
          answerText: answer.answer,
        );
      } else {
        log('Skipping answer: ${answer.questionId}');
        // Skip answers that are not filled
        continue;
      }

      answersToSubmit.add(responseAnswer);
    }

    log('Submitting ${answersToSubmit.length} answers');

    // Submit all answers
    final success = await submitMultipleAnswers(answersToSubmit);

    log('Submit result: $success');

    if (success) {
      // Create a dummy ResponseAnswer to satisfy the type requirement
      final dummyAnswer = ResponseAnswer(
        response: Response(id: responseId),
        question: Question(id: 0),
      );
      _submitAnswerResponse = ApiResponse.success(dummyAnswer);
    } else {
      log('Failed to submit some answers');
      _submitAnswerResponse =
          ApiResponse.error('Failed to submit some answers');
    }

    notifyListeners();
  }

  /// Sync pending answers when connectivity is restored
  Future<void> syncPendingAnswers() async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    await _surveyAnswerRepository.syncPendingAnswers();

    // Refresh current answers if we have a response ID
    if (_currentResponseId != null) {
      await fetchAnswersByResponseId(_currentResponseId!);
    }

    _isSyncing = false;
    notifyListeners();
  }

  void _processAnswers() {
    if (_answersResponse.data != null) {
      answerList.clear();
      for (var answer in answersResponse.data!) {
        final answerModel = AnswerModel(
            id: answer.id,
            questionId: answer.question?.id,
            optionId: answer.answerOption?.id,
            answer: answer.answerText,
            isChecked: false);
        answerList.add(answerModel);
      }
    }
  }

  /// Get all pending answers that haven't been synced yet
  Future<List<ResponseAnswer>?> getPendingAnswers() async {
    return await SurveyAnswerLocalStorage.getPendingAnswers();
  }

  /// Check if there are any pending answers
  Future<bool> hasPendingAnswers() async {
    final pendingAnswers = await getPendingAnswers();
    return pendingAnswers != null && pendingAnswers.isNotEmpty;
  }

  /// Clear all answers and reset state
  // void resetAnswers() {
  //   _answersResponse = ApiResponse.idle();
  //   _submitAnswerResponse = ApiResponse.idle();
  //   _updateAnswerResponse = ApiResponse.idle();
  //   _currentResponseId = null;
  //   answerList.clear();
  //   notifyListeners();
  // }
}
