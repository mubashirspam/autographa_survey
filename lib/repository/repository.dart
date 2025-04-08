// import 'dart:developer';

// import '../model/model.dart';
// import '../utils/utlis.dart';

// class Repository {
//   static final Repository _instance = Repository._internal();
//   factory Repository() => _instance;
//   Repository._internal();


//   /// Get questions by survey ID
//   Future<ApiResponse<List<Question>>> fetchQuestionBySurvey(String id) async {
//     final response =
//         await ApiHelper.get<List<dynamic>>('$epQuestionBySurvey/$id');
//     if (response.isSuccess && response.data != null) {
//       final questions = response.data!
//           .map((json) => Question.fromJson(json as Map<String, dynamic>))
//           .toList();
//       return ApiResponse.success(questions);
//     }
//     return ApiResponse.error(response.error!);
//   }

//   // ==================== ANSWER OPTIONS API ====================

//   /// Get all answer options
//   Future<ApiResponse<List<AnswerOption>>> getAllAnswerOptions() async {
//     final response = await ApiHelper.get<List<dynamic>>(epAnswerOption);
//     if (response.isSuccess && response.data != null) {
//       final options = response.data!
//           .map((json) => AnswerOption.fromJson(json as Map<String, dynamic>))
//           .toList();
//       return ApiResponse.success(options);
//     }
//     return ApiResponse.error(response.error!);
//   }

//   /// Get answer options by question ID
//   Future<ApiResponse<List<AnswerOption>>> getAllAnswerOptionsByQuestion(
//       String questionId) async {
//     final response = await ApiHelper.get<List<dynamic>>(
//         "$epAnswerOptionByQuestion/$questionId");
//     if (response.isSuccess && response.data != null) {
//       final options = response.data!
//           .map((json) => AnswerOption.fromJson(json as Map<String, dynamic>))
//           .toList();
//       return ApiResponse.success(options);
//     }
//     return ApiResponse.error(response.error!);
//   }



//   // ==================== RESPONSE ANSWERS API ====================

//   /// Get response answers by response ID
//   Future<ApiResponse<List<ResponseAnswer>>> fetchResponseAnswerByResponseId(
//       String id) async {
//     final response =
//         await ApiHelper.get<List<dynamic>>('$epAnswersByResponse/$id');
//     if (response.isSuccess && response.data != null) {
//       final answers = response.data!
//           .map((json) => ResponseAnswer.fromJson(json as Map<String, dynamic>))
//           .toList();
//       return ApiResponse.success(answers);
//     } else {
//       return ApiResponse.error(response.error!);
//     }
//   }

//   /// Create a new response answer
//   Future<ApiResponse<ResponseAnswer>> submitSurveyAnswers(
//       ResponseAnswer data) async {
//     final response = await ApiHelper.post(epAnswers, data.toJson());

//     if (response.isSuccess && response.data != null) {
//       final answer = ResponseAnswer.fromJson(response.data);
//       log("submitSurveyAnswers:${answer.id} with QuestionId:${answer.question!.id}");
//       return ApiResponse.success(answer);
//     } else {
//       return ApiResponse.error(response.error!);
//     }
//   }

//   /// Update an existing response answer
//   Future<ApiResponse<ResponseAnswer>> updateSurveyAnswers(
//       ResponseAnswer data, int id) async {
//     final dataJson = data.toJson();
//     dataJson['id'] = id;
//     final response = await ApiHelper.put(epAnswers, dataJson);

//     if (response.isSuccess && response.data != null) {
//       final answer = ResponseAnswer.fromJson(response.data);
//       log("updateSurveyAnswers:${answer.id} with QuestionId:${answer.question!.id}");
//       return ApiResponse.success(answer);
//     } else {
//       return ApiResponse.error(response.error!);
//     }
//   }
// }
