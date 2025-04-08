import 'dart:developer';

import '../data/survey_answer_local_storage.dart';
import '../model/model.dart';
import '../provider/connectivity_provider.dart';
import '../utils/utlis.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SurveyAnswerRepository {
  static final SurveyAnswerRepository _instance =
      SurveyAnswerRepository._internal();
  factory SurveyAnswerRepository() => _instance;
  SurveyAnswerRepository._internal();

  Future<void> syncPendingAnswers() async {
    if (!_isConnected(null)) return;

    final pendingAnswers = await SurveyAnswerLocalStorage.getPendingAnswers();
    if (pendingAnswers == null || pendingAnswers.isEmpty) return;

    final successfulSyncs = <ResponseAnswer>[];

    for (final answer in pendingAnswers) {
      try {
        if (answer.id == null) {
          final response = await ApiHelper.post(epAnswers, answer.toJson());
          if (response.isSuccess && response.data != null) {
            final syncedAnswer = ResponseAnswer.fromJson(response.data);
            await SurveyAnswerLocalStorage.addAnswer(syncedAnswer);
            successfulSyncs.add(answer);
          }
        } else {
          final response = await ApiHelper.put(epAnswers, answer.toJson());
          if (response.isSuccess && response.data != null) {
            final syncedAnswer = ResponseAnswer.fromJson(response.data);
            await SurveyAnswerLocalStorage.addAnswer(syncedAnswer);
            successfulSyncs.add(answer);
          }
        }
      } catch (e) {
        log('Error syncing answer: $e');
      }
    }

    if (successfulSyncs.isNotEmpty) {
      final remainingPending = pendingAnswers
          .where((answer) => !successfulSyncs.any((synced) =>
              (synced.id != null && synced.id == answer.id) ||
              (synced.question?.id == answer.question?.id &&
                  synced.response?.id == answer.response?.id)))
          .toList();

      if (remainingPending.isEmpty) {
        await SurveyAnswerLocalStorage.clearPendingAnswers();
      } else {
        await SurveyAnswerLocalStorage.savePendingAnswers(remainingPending);
      }
    }
  }

  bool _isConnected(BuildContext? context) {
    if (context == null) return true; // Default to true if no context
    return Provider.of<ConnectivityProvider>(context, listen: false)
        .isConnected;
  }

  // Reference to the connectivity provider
  final _connectivityProvider = ConnectivityProvider();

  Stream<ApiResponse<List<ResponseAnswer>>> fetchResponseAnswerByResponseId(
      String id) async* {
    try {
      // First fetch from local storage
      final cachedAnswers =
          await SurveyAnswerLocalStorage.getAnswersByResponseId(id);

      // Emit local data immediately if available
      if (cachedAnswers != null && cachedAnswers.isNotEmpty) {
        debugPrint('Emitting cached survey answers');
        yield ApiResponse.success(cachedAnswers);
      }

      // Check if we're online before attempting network request
      final bool isOnline = _connectivityProvider.isConnected;
      debugPrint('Network status: ${isOnline ? 'Online' : 'Offline'}');

      if (isOnline) {
        // Always try to fetch from network if online
        try {
          final response =
              await ApiHelper.get<List<dynamic>>('$epAnswersByResponse/$id');
          log('Network request for survey answers');

          if (response.isSuccess && response.data != null) {
            final answers = response.data!
                .map((json) =>
                    ResponseAnswer.fromJson(json as Map<String, dynamic>))
                .toList();

            // Save to local storage
            await SurveyAnswerLocalStorage.saveSurveyAnswers(answers);

            // Emit updated data from network
            debugPrint('Emitting fresh survey answers from network');
            yield ApiResponse.success(answers);
          } else if (cachedAnswers != null) {
            // If network request failed but we haven't emitted cached data yet
            if (cachedAnswers.isNotEmpty) {
              debugPrint('Network request failed, falling back to cached data');
              yield ApiResponse.success(cachedAnswers);
            }
          } else {
            // No cached data and network request failed
            yield ApiResponse.error(
                response.error ?? 'Failed to fetch data from network');
          }
        } catch (e) {
          debugPrint('Network error: $e');
          // Fall back to cached data if network request fails and we haven't emitted it yet
          if (cachedAnswers != null && cachedAnswers.isNotEmpty) {
            yield ApiResponse.success(cachedAnswers);
          } else {
            // No cached data and network request failed
            yield ApiResponse.error('Failed to fetch survey answers: $e');
          }
        }
      } else {
        // Offline and haven't emitted cached data yet
        if (cachedAnswers != null && cachedAnswers.isNotEmpty) {
          debugPrint('Device is offline, using cached data');
          yield ApiResponse.success(cachedAnswers);
        } else {
          // No cached data and offline
          yield ApiResponse.error('No data available and device is offline');
        }
      }
    } catch (e) {
      yield ApiResponse.error('Failed to fetch survey answers: $e');
    }
  }

  Future<ApiResponse<ResponseAnswer>> submitSurveyAnswers(ResponseAnswer data,
      {BuildContext? context}) async {
    log('Data: ${data.id} :${data.toJson()}');
    await SurveyAnswerLocalStorage.addAnswer(data);

    final isConnected = _isConnected(context);

    if (isConnected) {
      log('Data: ${data.id} :${data.toJson()}');
      final response = await ApiHelper.post(epAnswers, data.toJson());

      if (response.isSuccess && response.data != null) {
        final answer = ResponseAnswer.fromJson(response.data);
        log("submitSurveyAnswers:${answer.id} with QuestionId:${answer.question!.id}");

        await SurveyAnswerLocalStorage.addAnswer(answer);

        return ApiResponse.success(answer);
      } else {
        await SurveyAnswerLocalStorage.addPendingAnswer(data);
        return ApiResponse.error(response.error!);
      }
    } else {
      await SurveyAnswerLocalStorage.addPendingAnswer(data);

      return ApiResponse.success(data,
          message: 'Saved locally, will sync when online');
    }
  }

  Future<ApiResponse<ResponseAnswer>> updateSurveyAnswers(
      ResponseAnswer data, int id,
      {BuildContext? context}) async {
    log('Update Data: $id :${data.toJson()}');
    final updatedData = data.copyWith(id: id);

    await SurveyAnswerLocalStorage.addAnswer(updatedData);

    final isConnected = _isConnected(context);

    if (isConnected) {
      final dataJson = updatedData.toJson();
      final response = await ApiHelper.put(epAnswers, dataJson);

      if (response.isSuccess && response.data != null) {
        final answer = ResponseAnswer.fromJson(response.data);
        log("updateSurveyAnswers:${answer.id} with QuestionId:${answer.question!.id}");

        await SurveyAnswerLocalStorage.addAnswer(answer);

        return ApiResponse.success(answer);
      } else {
        await SurveyAnswerLocalStorage.addPendingAnswer(updatedData);
        return ApiResponse.error(response.error!);
      }
    } else {
      await SurveyAnswerLocalStorage.addPendingAnswer(updatedData);

      return ApiResponse.success(updatedData,
          message: 'Updated locally, will sync when online');
    }
  }
}
