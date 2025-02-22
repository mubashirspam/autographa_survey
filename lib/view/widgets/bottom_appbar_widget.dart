import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../provider/survey_provider.dart';

class BottomAppbarWidget extends StatelessWidget {
  final String surveyId;
  final String userId;

  const BottomAppbarWidget(
      {super.key, required this.surveyId, required this.userId});

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
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!provider.isFirstQuestion) const SizedBox(width: 30),
            Expanded(
              child: FilledButton(
                onPressed: provider.isLastQuestion
                    ? provider.canSubmit
                        ? () async {
                            final success = await provider.submitSurveyAnswers(
                                surveyId, userId);
                            if (success && context.mounted) {
                              Navigator.of(context)
                                  .pop(); // Return to survey list
                            }
                          }
                        : null
                    : provider.nextQuestion,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: provider.isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator())
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.isLastQuestion ? 'Submit' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
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
            ),
          ],
        ),
      ),
    );
  }
}
