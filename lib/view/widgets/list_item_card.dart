import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../model/response_model.dart';
import '../../provider/home_provider.dart';
import '../question_screens.dart';

class ListItemCard extends StatelessWidget {
  final int index;
  final bool isSelected;
  final Response surveyData;
  final bool isDesktop;

  const ListItemCard({
    super.key,
    required this.index,
    required this.surveyData,
    required this.isSelected,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isSelected && isDesktop
          ? Theme.of(context).primaryColor
          : isDesktop
              ? Theme.of(context).canvasColor
              : Colors.white,
      margin: EdgeInsets.only(bottom: 10),
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
          final homeProvider =
              Provider.of<HomeProvider>(context, listen: false);
          homeProvider.selectSurvey(surveyData.id!);
          
          if (!isDesktop && surveyData.survey != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionScreen(
                  response: surveyData,
                ),
              ),
            );
          }
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDesktop ? Colors.white : Theme.of(context).canvasColor,
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
          surveyData.survey?.survey ?? '',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          'Autographa',
          style: TextStyle(
              color: isSelected && isDesktop ? Colors.white : Colors.grey),
        ),
        trailing: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: isSelected && isDesktop
                ? Colors.white
                : Theme.of(context).primaryColor,
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
