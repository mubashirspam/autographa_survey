import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse({this.data, this.error, required this.success});

  factory ApiResponse.success(T data) {
    return ApiResponse(data: data, success: true);
  }

  factory ApiResponse.error(String error) {
    return ApiResponse(error: error, success: false);
  }
}

class Repository {
  static const String _baseUrl =
      'https://iiziqpmvme.execute-api.us-east-1.amazonaws.com/Testing';

  Future<ApiResponse<List<dynamic>>> getSurveys() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surveys'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(data as List<dynamic>);
      } else {
        return ApiResponse.error(
            'Failed to fetch surveys. Status code: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<List<dynamic>>> fetchSurveyQuestions(
      String surveyId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/questionNoptions/$surveyId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(data as List<dynamic>);
      } else {
        return ApiResponse.error(
            'Failed to fetch survey questions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<dynamic>> submitSurveyAnswers(String requestBody) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/responseNanswers'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error(
            'Failed to submit survey answers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
