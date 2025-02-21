// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'model/survey_list_model.dart';


class HomeProvider extends ChangeNotifier {

  late List<SurveyList> _surveyList = [];
  List<SurveyList> get surveyList => _surveyList;

  Future<List<SurveyList>> getSurveyList(BuildContext context) async {

    var request = http.Request('GET', Uri.parse('https://iiziqpmvme.execute-api.us-east-1.amazonaws.com/Testing/surveys'));
    http.StreamedResponse streamedResponse = await request.send();
    http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Decode the response body with UTF-8
      final String responseString = utf8.decode(response.bodyBytes);

      // Parse the JSON after decoding
      _surveyList = surveyListFromJson(responseString);

      notifyListeners();
      return _surveyList;
    } else {
      throw Exception('Failed to load appointment list');
    }
  }

}
