import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/response_model.dart';
import '../provider/survey_provider.dart';
import 'widgets/bottom_appbar_widget.dart';
import 'widgets/header_text_widget.dart';
import 'widgets/question_widget.dart';

class QuestionScreen extends StatelessWidget {
  final Response response;
  const QuestionScreen({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SurveyProvider>(context, listen: false);
      provider.loadQuestionsScreen(response, isRefresh: false);
    });
    return Scaffold(
      // extendBody: true,
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppbarWidget(response: response),
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(response.survey!.survey ?? ''),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              final provider =
                  Provider.of<SurveyProvider>(context, listen: false);
              provider.isFirstQuestion
                  ? Navigator.pop(context)
                  : provider.previousQuestion();
            },
          )),
      body: Consumer<SurveyProvider>(
        builder: (context, surveyProvider, child) {
          if (surveyProvider.questionResponse.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (surveyProvider.questionResponse.isError) {
            return Center(
                child: Text(surveyProvider.questionResponse.error ??
                    ' Something went wrong'));
          }
          if (surveyProvider.questionResponse.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (surveyProvider.questionResponse.isSuccess &&
              surveyProvider.questionList.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeaderText(surveyProvider.currentQuestionIndex + 1,
                      surveyProvider.questionList.length),
                  const SizedBox(height: 20),
                  Expanded(
                    child: QuestionWidget(
                      question: surveyProvider
                          .questionList[surveyProvider.currentQuestionIndex],
                    ),
                  ),
                  // SizedBox(height: 100)
                ],
              ),
            );
          }
          return const Center(child: Text("No questions available"));
        },
      ),
    );
  }
}
