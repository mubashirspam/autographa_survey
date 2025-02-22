import 'dart:convert';
import 'package:dio/dio.dart';

import '../model/survey_list_model.dart';
import '../model/survey_question_model.dart';

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
  final Dio _dio;
  static const String _baseUrl =
      ''; // TODO: replace with actual URL

  Repository()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ));

  Future<ApiResponse<List<SurveyList>>> getSurveys() async {
    try {
      final response = await _dio.get('/surveys');

      if (response.statusCode == 200) {
        return ApiResponse.success(
            surveyListFromJson(json.encode(response.data)));
      } else {
        return ApiResponse.error(
            'Failed to fetch surveys. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Error: ${e.toString()}');
    }
  }

  Future<ApiResponse<List<SurveyQuestionModel>>> fetchSurveyQuestions(
      String surveyId) async {
    try {
      final response = await _dio.get('/questionNoptions/$surveyId');

      if (response.statusCode == 200) {
        return ApiResponse.success(
            surveyQuestionModelFromJson(json.encode(response.data)));
      } else {
        return ApiResponse.error(
            'Failed to fetch survey questions. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Error: ${e.toString()}');
    }
  }

  Future<ApiResponse<dynamic>> submitSurveyAnswers(String requestBody) async {
    try {
      final response = await _dio.post(
        '/responseNanswers',
        data: json.decode(requestBody), // Convert string to JSON
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(
            'Failed to submit survey answers. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Error: ${e.toString()}');
    }
  }
}
