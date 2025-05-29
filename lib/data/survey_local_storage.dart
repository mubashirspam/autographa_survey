import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

/// A utility class for handling local storage operations using SharedPreferences
class SurveyLocalStorage {
  static const String _surveyListKey = 'survey_list';

  static const String _lastFetchTimeKey = 'last_fetch_time';

  /// Save survey list data to local storage
  static Future<bool> saveSurveyList(
      String personId, List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      log('Saving survey list to local storage: $jsonString');

      // Save the current timestamp along with the data
      await prefs.setString(
          _lastFetchTimeKey, DateTime.now().toIso8601String());

      return await prefs.setString("${_surveyListKey}_$personId", jsonString);
    } catch (e) {
      print('Error saving survey list: $e');
      return false;
    }
  }

  /// Get survey list data from local storage
  static Future<List<dynamic>?> getSurveyList(String personId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString("${_surveyListKey}_$personId");

      if (jsonString == null) {
        return null;
      }

      return jsonDecode(jsonString) as List<dynamic>;
    } catch (e) {
      print('Error getting survey list: $e');
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
  static Future<bool> isCacheStale(
      {Duration staleDuration = const Duration(hours: 1)}) async {
    final lastFetchTime = await getLastFetchTime();

    if (lastFetchTime == null) {
      return true;
    }

    final now = DateTime.now();
    return now.difference(lastFetchTime) > staleDuration;
  }

  /// Clear all stored data
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('Error clearing storage: $e');
      return false;
    }
  }
}
