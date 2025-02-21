import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SurveyScreen extends StatefulWidget {
  final String name;
  final String surveyId;
  final String userId;

  const SurveyScreen({
    super.key,
    required this.name,
    required this.surveyId,
    required this.userId,
  });

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  List<dynamic> surveyData = [];
  Map<int, int?> selectedAnswers =
      {}; // Stores selected optionId for each questionId
  Map<int, String?> textAnswers =
      {}; // Stores text field answers for each questionId
  bool isSubmitEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSurveyData();
  }

  Future<void> fetchSurveyData() async {
    var request = http.Request(
      'GET',
      Uri.parse(
          'https://iiziqpmvme.execute-api.us-east-1.amazonaws.com/Testing/questionNoptions/1'),
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      setState(() {
        surveyData = jsonDecode(responseBody);
      });
    } else {
      print("Error: ${response.reasonPhrase}");
    }
  }

  void checkIfAllAnswered() {
    bool allAnswered = surveyData.every((parent) {
      return parent['childQuestions'].every((child) {
        bool hasAnswer = selectedAnswers.containsKey(child['questionId']);

        if (child['answerOptions'] == null || child['answerOptions'].isEmpty) {
          // Check if text field answer exists for questions without options
          hasAnswer = textAnswers.containsKey(child['questionId']) &&
              textAnswers[child['questionId']]?.isNotEmpty == true;
        }

        return hasAnswer;
      });
    });

    setState(() {
      isSubmitEnabled = allAnswered;
    });
  }

  void onOptionSelected(int questionId, int optionId) {
    setState(() {
      selectedAnswers[questionId] = optionId;
      checkIfAllAnswered();
    });
  }

  void onTextAnswerChanged(int questionId, String value) {
    setState(() {
      textAnswers[questionId] = value;
      checkIfAllAnswered();
    });
  }

  Future<void> submitSurvey() async {
    setState(() {
      _isLoading = true;
    });
    if (isSubmitEnabled) {
      // Prepare the answers array for submission
      List<Map<String, dynamic>> answers = [];

      // Add answers with selected options
      selectedAnswers.forEach((questionId, answerOptionId) {
        if (answerOptionId != null) {
          answers.add({
            "answerOptionId": answerOptionId,
            "questionId": questionId,
            "text": "", // Empty text since the answer has an option
          });
        }
      });

      // Add text answers
      textAnswers.forEach((questionId, answerText) {
        if (answerText != null && answerText.isNotEmpty) {
          answers.add({
            "answerOptionId": "", // Empty answerOptionId for text answers
            "questionId": questionId,
            "text": answerText,
          });
        }
      });

      // API request to submit answers
      var headers = {
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(
            'https://iiziqpmvme.execute-api.us-east-1.amazonaws.com/Testing/responseNanswers'),
      );

      request.body = json.encode({
        "surveyId": widget.surveyId, // Passing surveyId from widget
        "userId": widget.userId, // Passing userId from widget
        "answers": answers,
      });

      request.headers.addAll(headers);

      // Send the request
      http.StreamedResponse response = await request.send();

      setState(() {
        _isLoading = false;
      });

      // Handle the response
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print("Survey Submitted: $responseBody");
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Survey submitted successfully!')));
      } else {
        print("Error: ${response.reasonPhrase}");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to submit survey')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the device is a tablet (wide screen) based on width
    bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Top bar color set to white
        elevation: 0, // No shadow
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    height: 70,
                    width: double.infinity,
                    color: Colors.white, // Top bar color set to white
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back_ios)),
                        Text(
                          widget.name,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 2,
                  ),
                  Expanded(
                    child: surveyData.isEmpty
                        ? Center(
                            child:
                                CircularProgressIndicator()) // Show loading if data is empty
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Loop through parent questions and child questions
                                ...surveyData.map<Widget>((parent) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Parent Question as Heading
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          parent['questionText'],
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      // Child Questions with Options or TextField if none exist
                                      if (parent['childQuestions'] != null &&
                                          parent['childQuestions'].isNotEmpty)
                                        Column(
                                          children: parent['childQuestions']
                                              .map<Widget>((child) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25)),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey),
                                                color: Colors.white,
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8),
                                              child: Padding(
                                                padding: EdgeInsets.all(15),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      child['questionText'],
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    if (child['answerOptions'] !=
                                                            null &&
                                                        child['answerOptions']
                                                            .isNotEmpty)
                                                      Column(
                                                        children: child[
                                                                'answerOptions']
                                                            .map<Widget>(
                                                                (option) {
                                                          return RadioListTile<
                                                              int>(
                                                            title: Text(option[
                                                                'optionValue']),
                                                            value: option[
                                                                'optionId'],
                                                            groupValue:
                                                                selectedAnswers[
                                                                    child[
                                                                        'questionId']],
                                                            onChanged: (value) {
                                                              onOptionSelected(
                                                                  child[
                                                                      'questionId'],
                                                                  value!);
                                                            },
                                                          );
                                                        }).toList(),
                                                      )
                                                    else
                                                      TextField(
                                                        onChanged: (value) {
                                                          onTextAnswerChanged(
                                                              child[
                                                                  'questionId'],
                                                              value);
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "Enter your answer",
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      // If no child questions, show TextField
                                      if (parent['childQuestions'] == null ||
                                          parent['childQuestions'].isEmpty)
                                        Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                          child: TextField(
                                            onChanged: (value) {
                                              // Handle the input for this parent question
                                              // Can use textAnswers[parent['questionId']] = value if needed
                                              onTextAnswerChanged(
                                                  parent['questionId'], value);
                                            },
                                            decoration: InputDecoration(
                                              hintText: "Enter your answer",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(25))),
                                            ),
                                            maxLength: 5,
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                                // Submit Button at the End of the Page
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          isSubmitEnabled ? submitSurvey : null,
                                      style: ElevatedButton.styleFrom(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        textStyle: TextStyle(fontSize: 18),
                                      ), // Enabled only when all answered
                                      child: Text(
                                        "Submit",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
