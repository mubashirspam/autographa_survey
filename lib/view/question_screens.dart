import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/provider.dart';
import '../router/app_router.dart';
import 'widgets/bottom_appbar_widget.dart';
import 'widgets/header_text_widget.dart';
import 'widgets/question_widget.dart';

class QuestionScreen extends StatelessWidget {
  final int responseId;
  const QuestionScreen({
    super.key,
    required this.responseId,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false)
          .fetchSurveysByResponseId(responseId, context);
    });
    return Scaffold(
      // extendBody: true,
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppbarWidget(responseId: responseId),
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Consumer<HomeProvider>(builder: (context, provider, child) {
            if (provider.singleSurveyResponse.isSuccess &&
                provider.singleSurveyResponse.data != null) {
              return Text(
                  provider.singleSurveyResponse.data!.survey?.survey ?? '');
            }
            return const Text('');
          }),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              final provider =
                  Provider.of<QuestionProvider>(context, listen: false);
              if (provider.isFirstQuestion) {
                // Go back to home screen using go_router
                context.go(ScreenPaths.home);
              } else {
                // Stay on the same screen but go to previous question
                provider.previousQuestion();
              }
            },
          )),
      body: Consumer<QuestionProvider>(
        builder: (context, questionProvider, child) {
          if (questionProvider.questionResponse.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (questionProvider.questionResponse.isError) {
            return Center(
                child: Text(questionProvider.questionResponse.error ??
                    ' Something went wrong'));
          }
          if (questionProvider.questionResponse.isSuccess &&
              questionProvider.questionList.isNotEmpty) {
           

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeaderText(questionProvider.currentQuestionIndex + 1,
                      questionProvider.questionList.length),
                  const SizedBox(height: 20),
                  Expanded(
                    child: QuestionWidget(
                      question: questionProvider
                          .questionList[questionProvider.currentQuestionIndex],
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
