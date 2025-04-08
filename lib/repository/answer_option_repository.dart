

import 'package:flutter/material.dart';
import '../data/answer_option_local_storage.dart';
import '../model/model.dart';
import '../utils/utlis.dart';
import '../provider/connectivity_provider.dart';

class AnswerOptionRepository {
  static final AnswerOptionRepository _instance = AnswerOptionRepository._internal();
  factory AnswerOptionRepository() => _instance;
  AnswerOptionRepository._internal();
  
  // Reference to the connectivity provider
  final _connectivityProvider = ConnectivityProvider();

  /// Get all answer options
  /// Returns a Stream of ApiResponse<List<AnswerOption>> that will emit:
  /// 1. Local data first (if available)
  /// 2. Remote data after fetching (if online)
  Stream<ApiResponse<List<AnswerOption>>> getAllAnswerOptions() async* {

      // First fetch from local storage
      final cachedOptions = await AnswerOptionLocalStorage.getAllAnswerOptions();
      
      // Emit local data immediately if available
      if (cachedOptions != null && cachedOptions.isNotEmpty) {
        debugPrint('Emitting cached answer options');
        yield ApiResponse.success(cachedOptions);
      }
      
      // Check if we're online before attempting network request
      final bool isOnline = _connectivityProvider.isConnected;
      debugPrint('Network status: ${isOnline ? 'Online' : 'Offline'}');
      
      if (isOnline) {
        // Always try to fetch from network if online
        try {
          final response = await ApiHelper.get<List<dynamic>>(epAnswerOption);
          
          if (response.isSuccess && response.data != null) {
            final options = response.data!
                .map((json) => AnswerOption.fromJson(json as Map<String, dynamic>))
                .toList();
            
            // Save to local storage
            await AnswerOptionLocalStorage.saveAllAnswerOptions(options);
            
            // Emit updated data from network
            debugPrint('Emitting fresh answer options from network');
            yield ApiResponse.success(options);
          } else if (cachedOptions != null) {
            // If network request failed but we haven't emitted cached data yet
            if (cachedOptions.isNotEmpty) {
              debugPrint('Network request failed, falling back to cached answer options');
              yield ApiResponse.success(cachedOptions, 
                  message: 'Using cached data. Network request failed: ${response.error}');
            }
          } else {
            // No cached data and network request failed
            yield ApiResponse.error(response.error ?? 'Failed to fetch answer options');
          }
        } catch (e) {
          debugPrint('Network error: $e');
          // Fall back to cached data if network request fails and we haven't emitted it yet
          if (cachedOptions != null && cachedOptions.isNotEmpty) {
            yield ApiResponse.success(cachedOptions, 
                message: 'Using cached data. Network error: $e');
          } else {
            // No cached data and network request failed
            yield ApiResponse.error('Failed to fetch answer options: $e');
          }
        }
      } else {
        // Offline and haven't emitted cached data yet
        if (cachedOptions != null && cachedOptions.isNotEmpty) {
          debugPrint('Device is offline, using cached answer options');
          yield ApiResponse.success(cachedOptions, 
              message: 'Device is offline. Using cached data.');
        } else {
          // No cached data and offline
          yield ApiResponse.error('No answer options available and device is offline');
        }
      }
    
  }

  /// Get answer options by question ID
  /// Returns a Stream of ApiResponse<List<AnswerOption>> that will emit:
  /// 1. Local data first (if available)
  /// 2. Remote data after fetching (if online)
  Stream<ApiResponse<List<AnswerOption>>> getAnswerOptionsByQuestion(String questionId) async* {
    try {
      // First fetch from local storage
      final cachedOptions = await AnswerOptionLocalStorage.getAnswerOptionsByQuestion(questionId);
      
      // Emit local data immediately if available
      if (cachedOptions != null && cachedOptions.isNotEmpty) {
        debugPrint('Emitting cached answer options for question $questionId');
        yield ApiResponse.success(cachedOptions);
      }
      
      // Check if we're online before attempting network request
      final bool isOnline = _connectivityProvider.isConnected;
      debugPrint('Network status: ${isOnline ? 'Online' : 'Offline'}');
      
      if (isOnline) {
        // Always try to fetch from network if online
        try {
          final response = await ApiHelper.get<List<dynamic>>("$epAnswerOptionByQuestion/$questionId");
          
          if (response.isSuccess && response.data != null) {
            final options = response.data!
                .map((json) => AnswerOption.fromJson(json as Map<String, dynamic>))
                .toList();
            
            // Cache the results for this question
            await AnswerOptionLocalStorage.saveAnswerOptionsByQuestion(questionId, options);
            
            // Emit updated data from network
            debugPrint('Emitting fresh answer options from network for question $questionId');
            yield ApiResponse.success(options);
          } else if (cachedOptions != null) {
            // If network request failed but we haven't emitted cached data yet
            if (cachedOptions.isNotEmpty) {
              debugPrint('Network request failed, falling back to cached answer options for question');
              yield ApiResponse.success(cachedOptions, 
                  message: 'Using cached data. Network request failed: ${response.error}');
            }
          } else {
            // No cached data and network request failed
            yield ApiResponse.error(response.error ?? 'Failed to fetch answer options for question');
          }
        } catch (e) {
          debugPrint('Network error: $e');
          // Fall back to cached data if network request fails and we haven't emitted it yet
          if (cachedOptions != null && cachedOptions.isNotEmpty) {
            yield ApiResponse.success(cachedOptions, 
                message: 'Using cached data. Network error: $e');
          } else {
            // No cached data and network request failed
            yield ApiResponse.error('Failed to fetch answer options for question: $e');
          }
        }
      } else {
        // Offline and haven't emitted cached data yet
        if (cachedOptions != null && cachedOptions.isNotEmpty) {
          debugPrint('Device is offline, using cached answer options for question');
          yield ApiResponse.success(cachedOptions, 
              message: 'Device is offline. Using cached data.');
        } else {
          // No cached data and offline
          yield ApiResponse.error('No answer options available for question and device is offline');
        }
      }
    } catch (e) {
      yield ApiResponse.error('Failed to fetch answer options for question: $e');
    }
  }


 

  /// Clear all cached answer options
  Future<bool> clearCache() async {
    return await AnswerOptionLocalStorage.clearAll();
  }
}
