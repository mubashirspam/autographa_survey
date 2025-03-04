import 'dart:developer';

import 'package:dio/dio.dart';
import 'api_response.dart';

class ApiHelper {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: '', // Added /api to base URL
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static String get baseUrl => _dio.options.baseUrl;

  static void initializeInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  static Future<ApiResponse<T>> get<T>(String endpoint) async {
    final url = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    log('GET ${baseUrl + url}', name: 'API');
    try {
      final response = await _dio.get(url);

      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  static Future<ApiResponse<T>> post<T>(String endpoint, dynamic data) async {
    final url = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    log('POST ${baseUrl + url}', name: 'API');
    try {
      final response = await _dio.post(url, data: data);

      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  static Future<ApiResponse<T>> put<T>(String endpoint, dynamic data) async {
    final url = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    log('PUT ${baseUrl + url}', name: 'API');
    try {
      final response = await _dio.put(url, data: data);

      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  static Future<ApiResponse<T>> delete<T>(String endpoint) async {
    final url = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    log('DELETE ${baseUrl + url}', name: 'API');
    try {
      final response = await _dio.delete(url);

      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  static String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Server error occurred';
        return 'Error $statusCode: $message';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'Network error occurred';
    }
  }
}
