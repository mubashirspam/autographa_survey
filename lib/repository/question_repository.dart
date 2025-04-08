import 'package:flutter/material.dart';
import '../data/question_local_storage.dart';
import '../model/model.dart';
import '../utils/utlis.dart';
import '../provider/connectivity_provider.dart';

class QuestionRepository {
  static final QuestionRepository _instance = QuestionRepository._internal();
  factory QuestionRepository() => _instance;
  QuestionRepository._internal();

  // Reference to the connectivity provider
  final _connectivityProvider = ConnectivityProvider();

  /// Get questions by survey ID
  /// Returns a Stream of ApiResponse<List<Question>> that will emit:
  /// 1. Local data first (if available)
  /// 2. Remote data after fetching (if online)
  Stream<ApiResponse<List<Question>>> fetchQuestionBySurvey(
      String surveyId) async* {
    // First fetch from local storage
    final cachedQuestions =
        await QuestionLocalStorage.getQuestionsBySurvey(surveyId);

    // Emit local data immediately if available
    if (cachedQuestions != null && cachedQuestions.isNotEmpty) {
      debugPrint('Emitting cached questions for survey $surveyId');
      yield ApiResponse.success(cachedQuestions);
    }

    // Check if we're online before attempting network request
    final bool isOnline = _connectivityProvider.isConnected;
    debugPrint('Network status: ${isOnline ? 'Online' : 'Offline'}');

    if (isOnline) {
      // Always try to fetch from network if online
      try {
        final response =
            await ApiHelper.get<List<dynamic>>('$epQuestionBySurvey/$surveyId');

        if (response.isSuccess && response.data != null) {
          final questions = response.data!
              .map((json) => Question.fromJson(json as Map<String, dynamic>))
              .toList();

          // Save to local storage
          await QuestionLocalStorage.saveQuestionsBySurvey(surveyId, questions);

          // Emit updated data from network
          debugPrint(
              'Emitting fresh questions from network for survey $surveyId');
          yield ApiResponse.success(questions);
        } else if (cachedQuestions != null) {
          // If network request failed but we haven't emitted cached data yet
          if (cachedQuestions.isNotEmpty) {
            debugPrint(
                'Network request failed, falling back to cached questions');
            yield ApiResponse.success(cachedQuestions,
                message:
                    'Using cached data. Network request failed: ${response.error}');
          }
        } else {
          // No cached data and network request failed
          yield ApiResponse.error(
              response.error ?? 'Failed to fetch questions');
        }
      } catch (e) {
        debugPrint('Network error: $e');
        // Fall back to cached data if network request fails and we haven't emitted it yet
        if (cachedQuestions != null && cachedQuestions.isNotEmpty) {
          yield ApiResponse.success(cachedQuestions,
              message: 'Using cached data. Network error: $e');
        } else {
          // No cached data and network request failed
          yield ApiResponse.error('Failed to fetch questions: $e');
        }
      }
    } else {
      // Offline and haven't emitted cached data yet
      if (cachedQuestions != null && cachedQuestions.isNotEmpty) {
        debugPrint('Device is offline, using cached questions');
        yield ApiResponse.success(cachedQuestions,
            message: 'Device is offline. Using cached data.');
      } else {
        // No cached data and offline
        yield ApiResponse.error('No questions available and device is offline');
      }
    }
  }

  /// Get a specific question by ID
  Future<ApiResponse<Question>> getQuestionById(int questionId) async {
    final response = await ApiHelper.get<Map<String, dynamic>>(
        '$epQuestionBySurvey/$questionId');

    if (response.isSuccess && response.data != null) {
      final question = Question.fromJson(response.data!);
      return ApiResponse.success(question);
    }

    return ApiResponse.error(response.error ?? 'Failed to fetch question');
  }

  /// Clear cached questions for a specific survey
  Future<bool> clearCacheBySurvey(String surveyId) async {
    return await QuestionLocalStorage.clearQuestionsBySurvey(surveyId);
  }

  /// Clear all cached questions
  Future<bool> clearCache() async {
    return await QuestionLocalStorage.clearAll();
  }
}
