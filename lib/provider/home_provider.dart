import 'package:flutter/material.dart';
import '../model/model.dart';
import '../utils/utlis.dart';
import 'repository.dart';

/// Provider class that manages the home screen state and API interactions
class HomeProvider extends ChangeNotifier {
  // ==================== PRIVATE VARIABLES ====================
  final _repository = Repository();

  // API Response states
  ApiResponse<List<Response>> _allSurveysResponse = ApiResponse.idle();

  // Selected survey state

  Response? _selectedResponse;

  // ==================== GETTERS ====================

  // Survey getters

  Response? get selectedResponse => _selectedResponse;

  ApiResponse<List<Response>> get surveyList => _allSurveysResponse;

  // ==================== SURVEY METHODS ====================

  void selectSurvey(int id) {
    _selectedResponse = surveyList.data?.firstWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> fetchAllSurveys({bool isRefresh = false}) async {
    if (!isRefresh &&
        (_allSurveysResponse.isLoading || _allSurveysResponse.isSuccess)) {
      return;
    }
    _allSurveysResponse = ApiResponse.loading();
    notifyListeners();
    _allSurveysResponse = await _repository.fetchSurveyResponses('1');
    notifyListeners();
  }
}
