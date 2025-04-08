import 'package:flutter/material.dart';

import '../model/model.dart';
import '../repository/answer_option_repository.dart';
import '../utils/utlis.dart';

class AnswerOptionProvider extends ChangeNotifier {
  static final AnswerOptionProvider _instance =
      AnswerOptionProvider._internal();
  factory AnswerOptionProvider() => _instance;
  AnswerOptionProvider._internal();
  // ==================== PRIVATE VARIABLES ====================
  final _repository = AnswerOptionRepository();

  // API Response states
  ApiResponse<List<AnswerOption>> _allOptionsResponse = ApiResponse.idle();
  ApiResponse<List<AnswerOption>> _optionsByQuestionResponse =
      ApiResponse.idle();

  // Cache for currently selected question options

  // ==================== GETTERS ====================

  // Response getters
  ApiResponse<List<AnswerOption>> get allOptionsResponse => _allOptionsResponse;
  ApiResponse<List<AnswerOption>> get optionsByQuestionResponse =>
      _optionsByQuestionResponse;

  // Data getters
  List<AnswerOption> get allOptions => _allOptionsResponse.data ?? [];
  List<AnswerOption> get currentQuestionOptions =>
      _optionsByQuestionResponse.data ?? [];

  // Status getters
  bool get isLoading =>
      _allOptionsResponse.isLoading || _optionsByQuestionResponse.isLoading;

  // ==================== PUBLIC METHODS ====================

  /// Fetch all answer options
  Future<void> fetchAllAnswerOptions() async {
    _allOptionsResponse = ApiResponse.loading();
    notifyListeners();

    try {
      // Listen to the stream of responses from the repository
      _repository.getAllAnswerOptions().listen(
        (response) {
          _allOptionsResponse = response;
          notifyListeners();
        },
        onError: (e) {
          _allOptionsResponse =
              ApiResponse.error('Failed to fetch answer options: $e');
          notifyListeners();
        },
        onDone: () {
          // Stream completed
        },
      );
    } catch (e) {
      _allOptionsResponse =
          ApiResponse.error('Failed to fetch answer options: $e');
      notifyListeners();
    }
  }

  /// Fetch answer options for a specific question
  Future<void> fetchAnswerOptionsByQuestion(String questionId) async {
    _optionsByQuestionResponse = ApiResponse.loading();
    notifyListeners();

    try {
      // Listen to the stream of responses from the repository
      _repository.getAnswerOptionsByQuestion(questionId).listen(
        (response) {
          _optionsByQuestionResponse = response;
          notifyListeners();
        },
        onError: (e) {
          _optionsByQuestionResponse = ApiResponse.error(
              'Failed to fetch answer options for question: $e');
          notifyListeners();
        },
        onDone: () {
          // Stream completed
        },
      );
    } catch (e) {
      _optionsByQuestionResponse =
          ApiResponse.error('Failed to fetch answer options for question: $e');
      notifyListeners();
    }
  }

  /// Get options for a specific question
  List<AnswerOption> getOptionsForQuestion(int questionId) {
    return allOptions
        .where((option) => option.question?.id == questionId)
        .toList();
  }

  /// Find an option by ID
  AnswerOption? findOptionById(int optionId) {
    try {
      return allOptions.firstWhere((option) => option.id == optionId);
    } catch (e) {
      return null;
    }
  }

  /// Clear all cached options
  Future<void> clearCache() async {
    await _repository.clearCache();
    reset();
  }

  /// Reset the provider state
  void reset() {
    _allOptionsResponse = ApiResponse.idle();
    _optionsByQuestionResponse = ApiResponse.idle();

    notifyListeners();
  }
}
