import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../model/model.dart';
import '../../provider/survey_provider.dart';

class BottomAppbarWidget extends StatelessWidget {
  final Response response;

  const BottomAppbarWidget({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0x00000000),
      child: Consumer<SurveyProvider>(
        builder: (context, provider, child) => Row(
          children: [
            if (!provider.isFirstQuestion)
              Expanded(
                child: FilledButton(
                  onPressed: provider.previousQuestion,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: 3.14,
                        child: SvgPicture.asset(
                          'assets/icons/arrow.svg',
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!provider.isFirstQuestion) const SizedBox(width: 30),
            SurveyButton(provider: provider, response: response),
          ],
        ),
      ),
    );
  }
}

class SurveyButton extends StatelessWidget {
  final SurveyProvider provider;
  final dynamic response;

  const SurveyButton({required this.provider, required this.response});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        onPressed: () {
          if (provider.isLastQuestion) {
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                if (provider.canSubmit) {
                  return CupertinoAlertDialog(
                    title: const Text('Confirm Submission'),
                    content: const Text(
                        'Are you sure you want to submit your answers?'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.of(context).pop(),
                        isDefaultAction: true,
                        child: const Text('Cancel'),
                      ),
                      CupertinoDialogAction(
                        onPressed: () async {
                         
                          await provider.submitSurveyAnswers(response);
                          if (provider.submitAnswerResponse.isSuccess &&
                              context.mounted) {
                            Navigator.of(context).pop();
                             Navigator.of(context).pop();
                          }
                        },
                        isDestructiveAction: true,
                        child:  const Text('Submit'),
                      ),
                    ],
                  );
                } else {
                  return CupertinoAlertDialog(
                    title: const Text('Incomplete Survey'),
                    content: const Text(
                        'Please answer all required questions before submitting.'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.of(context).pop(),
                        isDefaultAction: true,
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }
              },
            );
          } else {
            provider.nextQuestion();
          }
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: provider.submitAnswerResponse.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.isLastQuestion ? 'Submit' : 'Next',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!provider.isLastQuestion) ...[
                    const SizedBox(width: 10),
                    SvgPicture.asset('assets/icons/arrow.svg'),
                  ],
                ],
              ),
      ),
    );
  }
}
