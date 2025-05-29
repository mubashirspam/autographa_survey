import 'dart:developer';

import '../model/model.dart';
import '../data/survey_local_storage.dart';
import '../utils/utlis.dart';
import '../provider/connectivity_provider.dart';
import 'package:flutter/material.dart';

class SurveyRepository {
  static final SurveyRepository _instance = SurveyRepository._internal();
  factory SurveyRepository() => _instance;
  SurveyRepository._internal();

  // Reference to the connectivity provider
  final _connectivityProvider = ConnectivityProvider();

  Stream<ApiResponse<List<Response>>> fetchSurveyResponses(String id) async* {
    try {
      // First fetch from local storage
      final cachedData = await SurveyLocalStorage.getSurveyList(id);
      final cachedResponses = cachedData
          ?.map((json) => Response.fromJson(json as Map<String, dynamic>))
          .toList();

      // Emit local data immediately if available
      if (cachedResponses != null && cachedResponses.isNotEmpty) {
        log('Emitting cached survey responses');
        yield ApiResponse.success(cachedResponses);
      }

      // Check if we're online before attempting network request
      final bool isOnline = _connectivityProvider.isConnected;
      debugPrint('Network status: ${isOnline ? 'Online' : 'Offline'}');

      if (isOnline) {
        // Always try to fetch from network if online
        try {
          final response =
              await ApiHelper.get<List<dynamic>>('$epResponseByParticipant$id');

          if (response.isSuccess && response.data != null) {
            // Filter out any null or invalid entries before creating Response objects
            final validData = response.data!.where((json) => 
                json != null && json is Map<String, dynamic>).toList();
            
            debugPrint('Processing ${validData.length} valid responses');
            
            // Create Response objects from valid JSON data
            final responses = validData
                .map((json) => Response.fromJson(json as Map<String, dynamic>))
                .toList();
            
            debugPrint('Created ${responses.length} Response objects');
            
            // Convert to JSON safely with null checks
            final jsonList = responses
                .map((r) {
                  try {
                    return r.toJson(); // Convert each response to JSON
                  } catch (e) {
                    debugPrint('Error converting response to JSON: $e');
                    return null; // Return null for failed conversions
                  }
                })
                .where((json) => json != null) // Filter out any null JSON objects
                .toList();
            
            debugPrint('Saving ${jsonList.length} responses to local storage');
            
            // Save to local storage if we have valid JSON data
            if (jsonList.isNotEmpty) {
              await SurveyLocalStorage.saveSurveyList(id, jsonList);
            }

            // Emit updated data from network
            debugPrint('Emitting fresh survey responses from network');
            yield ApiResponse.success(responses);
          } else if (cachedResponses != null) {
            // If network request failed but we haven't emitted cached data yet
            if (cachedResponses.isNotEmpty) {
              debugPrint('Network request failed, falling back to cached data');
              yield ApiResponse.success(cachedResponses);
            }
          } else {
            debugPrint('Network request failed, no cached data available');
            yield ApiResponse.error(
                response.error ?? 'Failed to fetch data from network');
          }
        } catch (e) {
          debugPrint('Network error: $e');
          // Fall back to cached data if network request fails and we haven't emitted it yet
          if (cachedResponses != null && cachedResponses.isNotEmpty) {
            yield ApiResponse.success(cachedResponses);
          } else {
            debugPrint('No cached data available');
            yield ApiResponse.error('Failed to fetch survey responses: $e');
          }
        }
      } else {
        // Offline and haven't emitted cached data yet
        if (cachedResponses != null && cachedResponses.isNotEmpty) {
          debugPrint('Device is offline, using cached data');
          yield ApiResponse.success(cachedResponses);
        } else {
          debugPrint('No cached data available');
          yield ApiResponse.error('No data available and device is offline');
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch survey responses: $e');
      yield ApiResponse.error('Failed to fetch survey responses: $e');
    }
  }

  Future<ApiResponse<Response>> fetchSurveysByResponseId(String id) async {
    try {
      // First check if we have this response in local storage
      final cachedData = await SurveyLocalStorage.getSurveyList(id);
      if (cachedData != null && cachedData.isNotEmpty) {
        final cachedResponses = cachedData
            .map((json) => Response.fromJson(json as Map<String, dynamic>))
            .toList();

        // Try to find the response with the given ID
        final matchingResponse = cachedResponses.firstWhere(
          (response) => response.id.toString() == id,
          orElse: () => Response(), // Return empty response if not found
        );

        // If we found a valid response in local storage, return it
        if (matchingResponse.id != null) {
          debugPrint('Found response with ID $id in local storage');
          return ApiResponse.success(matchingResponse);
        }
      }

      final apiResponse =
          await ApiHelper.get<Map<String, dynamic>>('$epResponse/$id');

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final response = Response.fromJson(apiResponse.data!);
        return ApiResponse.success(response);
      } else {
        return ApiResponse.error(
            apiResponse.error ?? 'Failed to fetch response');
      }
    } catch (e) {
      debugPrint('Error fetching response by ID: $e');
      return ApiResponse.error('Failed to fetch response: $e');
    }
  }
}
