import 'package:flutter/material.dart';
import '../model/survey_list_model.dart';
import 'repository.dart';
import 'utils.dart';

class HomeProvider extends ChangeNotifier {
  final Repository _repository = Repository();
  LoadingState _state = LoadingState.idle;
  List<SurveyList> _surveyList = [];
  String? _error;

  // Getters
  LoadingState get state => _state;
  List<SurveyList> get surveyList => _surveyList;
  String? get error => _error;
  bool get isLoading => _state == LoadingState.loading;

  Future<List<SurveyList>> getSurveyList() async {
    try {
      _state = LoadingState.loading;
      _error = null;
      notifyListeners();

      final response = await _repository.getSurveys();

      if (response.success && response.data != null) {
        _surveyList = response.data!;
        _state = LoadingState.idle;
        return _surveyList;
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
