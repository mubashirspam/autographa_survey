import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:autographa_survey/model/survey_list_model.dart';

import '../survey_screens.dart';

// import '../survey_screen.dart';

class ListItemCard extends StatelessWidget {
  final int index;
  final SurveyList surveyData;

  const ListItemCard({
    super.key,
    required this.index,
    required this.surveyData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurveyScreen(
                survey: surveyData,
                // name: surveyData.surveyName,
                // surveyId: surveyData.id.toString(),
                // userId: '1',
              ),
            ),
          );
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              (index + 1).toString().padLeft(2, '0'),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        title: Text(
          surveyData.surveyName,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: const Text(
          'Autographa',
          style: TextStyle(color: Colors.grey),
        ),
        trailing: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset(
              'assets/icons/arrow.svg',
            ),
          ),
        ),
      ),
    );
  }
}
