import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/model.dart';
import '../repository/survey_repository.dart';
import '../utils/token_manager.dart';
import '../utils/utlis.dart';
import 'question_provider.dart';

class HomeProvider extends ChangeNotifier {
  final _repository = SurveyRepository();

  ApiResponse<List<Response>> _allSurveysResponse = ApiResponse.idle();
  ApiResponse<Response> _singleSurveyResponse = ApiResponse.idle();
  ApiResponse<List<Response>> get surveyList => _allSurveysResponse;


  
  // Response? _selectedResponse;
  // Response? get selectedResponse => _selectedResponse;
  ApiResponse<Response> get singleSurveyResponse => _singleSurveyResponse;

  // void selectSurvey(int id) {
  //   _selectedResponse = surveyList.data?.firstWhere((r) => r.id == id);
  //   notifyListeners();
  // }

  Future<void> fetchAllSurveysByUserId() async {
    log('Fetching surveys for user ');
    if (_allSurveysResponse.isLoading) {
      log('Skipping fetch - already loading');
      return;
    }

    // Set loading state
    _allSurveysResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        return;
      }
      // Listen to the stream of responses from the repository
      _repository.fetchSurveyResponses(userId.toString()).listen(
        (response) {
          log('Received survey response update');
          _allSurveysResponse = response;
          notifyListeners();
        },
        onError: (e) {
          log('Stream error: $e');
          _allSurveysResponse =
              ApiResponse.error('Failed to fetch surveys: $e');
          notifyListeners();
        },
        onDone: () {
          log('Survey response stream completed');
        },
      );
    } catch (e) {
      _allSurveysResponse = ApiResponse.error('Failed to fetch surveys: $e');
      log('Failed to fetch surveys: $e');
      notifyListeners();
    }
  }

  Future<void> fetchSurveysByResponseId(
      int responseId, BuildContext context) async {
    log('Fetching survey with ID $responseId');
    if (_singleSurveyResponse.isLoading) {
      log('Skipping fetch - already loading');
      return;
    }
    _singleSurveyResponse = ApiResponse.loading();
    notifyListeners();
    final response =
        await _repository.fetchSurveysByResponseId(responseId.toString());
    _singleSurveyResponse = response;
    notifyListeners();
    if (response.isSuccess &&
        response.data != null &&
        response.data!.survey?.id != null) {
      Provider.of<QuestionProvider>(context, listen: false).loadQuestionsScreen(
          responseId.toString(), response.data!.survey!.id.toString());
    }
  }
}
