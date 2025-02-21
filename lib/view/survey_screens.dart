import 'package:autographa_survey/model/survey_list_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/survey_provider.dart';
import '../provider/utils.dart';
import 'widgets/bottom_appbar_widget.dart';
import 'widgets/question_widget.dart';

class SurveyScreen extends StatelessWidget {
  final SurveyList survey;
  const SurveyScreen({super.key, required this.survey});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SurveyProvider>(context, listen: false);
      provider.fetchSurveyQuestions(survey.id.toString());
    });
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppbarWidget( 
        surveyId: survey.id.toString(),
        userId: '1',
      ),
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(survey.surveyName),
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
          if (surveyProvider.state == LoadingState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (surveyProvider.state == LoadingState.error) {
            return Center(child: Text(surveyProvider.error!));
          }
          if (surveyProvider.state == LoadingState.idle &&
              surveyProvider.surveyQuestionsList.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Question ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        TextSpan(
                          text: (surveyProvider.currentQuestionIndex + 1)
                              .toString()
                              .padLeft(2, '0'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text: '/${surveyProvider.surveyQuestionsList.length}',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: QuestionWidget(
                      question: surveyProvider.surveyQuestionsList[
                          surveyProvider.currentQuestionIndex],
                    ),
                  ),
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
