import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/model.dart';

/// A utility class for handling answer option local storage operations using SharedPreferences
class AnswerOptionLocalStorage {
  static const String _allOptionsKey = 'all_answer_options';
  static const String _optionsByQuestionPrefix = 'answer_options_question_';
  static const String _lastFetchTimeKey = 'last_options_fetch_time';

  /// Save all answer options to local storage
  static Future<bool> saveAllAnswerOptions(List<AnswerOption> options) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(options.map((option) => option.toJson()).toList());
      
      // Save the current timestamp along with the data
      await prefs.setString(_lastFetchTimeKey, DateTime.now().toIso8601String());
      
      return await prefs.setString(_allOptionsKey, jsonString);
    } catch (e) {
      print('Error saving all answer options: $e');
      return false;
    }
  }

  /// Get all answer options from local storage
  static Future<List<AnswerOption>?> getAllAnswerOptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_allOptionsKey);
      
      if (jsonString == null) {
        return null;
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => AnswerOption.fromJson(json)).toList();
    } catch (e) {
      print('Error getting all answer options: $e');
      return null;
    }
  }

  /// Save answer options for a specific question to local storage
  static Future<bool> saveAnswerOptionsByQuestion(String questionId, List<AnswerOption> options) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(options.map((option) => option.toJson()).toList());
      
      return await prefs.setString('$_optionsByQuestionPrefix$questionId', jsonString);
    } catch (e) {
      print('Error saving answer options by question: $e');
      return false;
    }
  }

  /// Get answer options for a specific question from local storage
  static Future<List<AnswerOption>?> getAnswerOptionsByQuestion(String questionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_optionsByQuestionPrefix$questionId');
      
      if (jsonString == null) {
        return null;
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => AnswerOption.fromJson(json)).toList();
    } catch (e) {
      print('Error getting answer options by question: $e');
      return null;
    }
  }

  /// Get the timestamp of the last fetch
  static Future<DateTime?> getLastFetchTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastFetchTimeKey);
      
      if (timeString == null) {
        return null;
      }
      
      return DateTime.parse(timeString);
    } catch (e) {
      print('Error getting last fetch time: $e');
      return null;
    }
  }

  /// Check if cached data is stale (older than specified duration)
  static Future<bool> isCacheStale({Duration staleDuration = const Duration(hours: 1)}) async {
    final lastFetchTime = await getLastFetchTime();
    
    if (lastFetchTime == null) {
      return true;
    }
    
    final now = DateTime.now();
    return now.difference(lastFetchTime) > staleDuration;
  }

  /// Clear all stored answer options
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all keys
      final keys = prefs.getKeys();
      
      // Filter keys related to answer options
      final optionKeys = keys.where((key) => 
        key == _allOptionsKey || 
        key == _lastFetchTimeKey || 
        key.startsWith(_optionsByQuestionPrefix)
      ).toList();
      
      // Remove all option-related keys
      for (final key in optionKeys) {
        await prefs.remove(key);
      }
      
      return true;
    } catch (e) {
      print('Error clearing answer options storage: $e');
      return false;
    }
  }
}
