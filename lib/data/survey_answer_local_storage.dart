import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/model.dart';

/// A utility class for handling survey answer local storage operations using SharedPreferences
class SurveyAnswerLocalStorage {
  static const String _surveyAnswersKey = 'survey_answers';
  static const String _pendingAnswersKey = 'pending_survey_answers';
  static const String _lastSyncTimeKey = 'last_answers_sync_time';

  /// Save survey answers to local storage
  static Future<bool> saveSurveyAnswers(List<ResponseAnswer> answers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(answers.map((answer) => answer.toJson()).toList());
      
      // Save the current timestamp along with the data
      await prefs.setString(_lastSyncTimeKey, DateTime.now().toIso8601String());
      
      return await prefs.setString(_surveyAnswersKey, jsonString);
    } catch (e) {
      print('Error saving survey answers: $e');
      return false;
    }
  }

  /// Get survey answers from local storage
  static Future<List<ResponseAnswer>?> getSurveyAnswers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_surveyAnswersKey);
      
      if (jsonString == null) {
        return null;
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ResponseAnswer.fromJson(json)).toList();
    } catch (e) {
      print('Error getting survey answers: $e');
      return null;
    }
  }

  /// Save pending survey answers (answers that couldn't be submitted due to connectivity issues)
  static Future<bool> savePendingAnswers(List<ResponseAnswer> answers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(answers.map((answer) => answer.toJson()).toList());
      
      return await prefs.setString(_pendingAnswersKey, jsonString);
    } catch (e) {
      print('Error saving pending survey answers: $e');
      return false;
    }
  }

  /// Get pending survey answers from local storage
  static Future<List<ResponseAnswer>?> getPendingAnswers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_pendingAnswersKey);
      
      if (jsonString == null) {
        return null;
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ResponseAnswer.fromJson(json)).toList();
    } catch (e) {
      print('Error getting pending survey answers: $e');
      return null;
    }
  }

  /// Clear pending answers after successful submission
  static Future<bool> clearPendingAnswers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_pendingAnswersKey);
    } catch (e) {
      print('Error clearing pending answers: $e');
      return false;
    }
  }

  /// Get survey answers for a specific survey response
  static Future<List<ResponseAnswer>?> getAnswersByResponseId(String responseId) async {
    try {
      final answers = await getSurveyAnswers();
      
      if (answers == null) {
        return null;
      }
      
      return answers.where((answer) => answer.response?.id == responseId).toList();
    } catch (e) {
      print('Error getting answers by response ID: $e');
      return null;
    }
  }

  /// Get the timestamp of the last sync
  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastSyncTimeKey);
      
      if (timeString == null) {
        return null;
      }
      
      return DateTime.parse(timeString);
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }

  /// Check if cached data is stale (older than specified duration)
  static Future<bool> isCacheStale({Duration staleDuration = const Duration(hours: 1)}) async {
    final lastSyncTime = await getLastSyncTime();
    
    if (lastSyncTime == null) {
      return true;
    }
    
    final now = DateTime.now();
    return now.difference(lastSyncTime) > staleDuration;
  }

  /// Add a single answer to local storage
  static Future<bool> addAnswer(ResponseAnswer answer) async {
    try {
      final answers = await getSurveyAnswers() ?? [];
      
      // Check if the answer already exists (by ID or by question+response combination)
      final existingIndex = answers.indexWhere((a) => 
        (a.id != null && a.id == answer.id) || 
        (a.question?.id == answer.question?.id && a.response?.id == answer.response?.id)
      );
      
      if (existingIndex >= 0) {
        // Update existing answer
        answers[existingIndex] = answer;
      } else {
        // Add new answer
        answers.add(answer);
      }
      
      return await saveSurveyAnswers(answers);
    } catch (e) {
      print('Error adding survey answer: $e');
      return false;
    }
  }

  /// Add a single answer to pending answers
  static Future<bool> addPendingAnswer(ResponseAnswer answer) async {
    try {
      final pendingAnswers = await getPendingAnswers() ?? [];
      
      // Check if the answer already exists in pending list
      final existingIndex = pendingAnswers.indexWhere((a) => 
        (a.id != null && a.id == answer.id) || 
        (a.question?.id == answer.question?.id && a.response?.id == answer.response?.id)
      );
      
      if (existingIndex >= 0) {
        // Update existing answer
        pendingAnswers[existingIndex] = answer;
      } else {
        // Add new answer
        pendingAnswers.add(answer);
      }
      
      return await savePendingAnswers(pendingAnswers);
    } catch (e) {
      print('Error adding pending survey answer: $e');
      return false;
    }
  }

  /// Clear all stored data
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_surveyAnswersKey);
      await prefs.remove(_pendingAnswersKey);
      await prefs.remove(_lastSyncTimeKey);
      return true;
    } catch (e) {
      print('Error clearing storage: $e');
      return false;
    }
  }
}
