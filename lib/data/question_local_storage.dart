import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/model.dart';

/// A utility class for handling question local storage operations using SharedPreferences
class QuestionLocalStorage {
  static const String _questionsBySurveyPrefix = 'questions_survey_';
  static const String _lastFetchTimePrefix = 'last_questions_fetch_time_';

  /// Save questions for a specific survey to local storage
  static Future<bool> saveQuestionsBySurvey(String surveyId, List<Question> questions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(questions.map((question) => question.toJson()).toList());
      
      // Save the current timestamp along with the data
      await prefs.setString('$_lastFetchTimePrefix$surveyId', DateTime.now().toIso8601String());
      
      return await prefs.setString('$_questionsBySurveyPrefix$surveyId', jsonString);
    } catch (e) {
      print('Error saving questions by survey: $e');
      return false;
    }
  }

  /// Get questions for a specific survey from local storage
  static Future<List<Question>?> getQuestionsBySurvey(String surveyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_questionsBySurveyPrefix$surveyId');
      
      if (jsonString == null) {
        return null;
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      print('Error getting questions by survey: $e');
      return null;
    }
  }

  /// Get the timestamp of the last fetch for a specific survey
  static Future<DateTime?> getLastFetchTime(String surveyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString('$_lastFetchTimePrefix$surveyId');
      
      if (timeString == null) {
        return null;
      }
      
      return DateTime.parse(timeString);
    } catch (e) {
      print('Error getting last fetch time: $e');
      return null;
    }
  }

  /// Check if cached data for a survey is stale (older than specified duration)
  static Future<bool> isCacheStale(String surveyId, {Duration staleDuration = const Duration(hours: 1)}) async {
    final lastFetchTime = await getLastFetchTime(surveyId);
    
    if (lastFetchTime == null) {
      return true;
    }
    
    final now = DateTime.now();
    return now.difference(lastFetchTime) > staleDuration;
  }

  /// Clear questions for a specific survey
  static Future<bool> clearQuestionsBySurvey(String surveyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_questionsBySurveyPrefix$surveyId');
      await prefs.remove('$_lastFetchTimePrefix$surveyId');
      return true;
    } catch (e) {
      print('Error clearing questions for survey: $e');
      return false;
    }
  }

  /// Clear all stored questions
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all keys
      final keys = prefs.getKeys();
      
      // Filter keys related to questions
      final questionKeys = keys.where((key) => 
        key.startsWith(_questionsBySurveyPrefix) || 
        key.startsWith(_lastFetchTimePrefix)
      ).toList();
      
      // Remove all question-related keys
      for (final key in questionKeys) {
        await prefs.remove(key);
      }
      
      return true;
    } catch (e) {
      print('Error clearing questions storage: $e');
      return false;
    }
  }
}
