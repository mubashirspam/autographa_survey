import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/survey_question_model.dart';
import '../../provider/survey_provider.dart';
import '../../provider/utils.dart';

class QuestionWidget extends StatefulWidget {
  final SurveyQuestionModel question;
  final int index;
  final bool isChild;

  const QuestionWidget({
    super.key,
    required this.question,
    this.isChild = false,
    this.index = 0,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding:
            widget.isChild ? const EdgeInsets.all(15) : const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border:
              widget.isChild ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.isChild
                    ? CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        radius: 18,
                        child: Text(
                          (widget.index).toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                if (widget.isChild) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.question.questionText?.trim() ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildQuestionContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    switch (widget.question.questionType) {
      case QuestionType.longAnswer:
        return _buildLongAnswer();
      case QuestionType.mcq:
        return _buildMultipleChoice();
      case QuestionType.parentQuestion:
        return _buildParentChild();
      default:
        return _buildLongAnswer();
    }
  }

  Widget _buildLongAnswer() {
    final provider = Provider.of<SurveyProvider>(context);
    final currentAnswer =
        provider.getTextAnswer(widget.question.questionId.toString());

    if (_controller.text != currentAnswer) {
      _controller.text = currentAnswer ?? '';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: currentAnswer?.length ?? 0),
      );
    }

    return TextField(
      controller: _controller,
      maxLines: 4,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter your answer',
        hintStyle: TextStyle(color: Colors.grey),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        fillColor: Colors.grey.shade100,
        filled: true,
      ),
      onChanged: (value) {
        provider.setAnswer(
          widget.question.questionId.toString(),
          text: value,
        );
      },
    );
  }

  Widget _buildMultipleChoice() {
    final provider = Provider.of<SurveyProvider>(context);
    final selectedOptionId =
        provider.getSelectedAnswer(widget.question.questionId.toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.question.answerOptions?.length ?? 0,
        (index) {
          final option = widget.question.answerOptions?[index];
          if (option == null) return const SizedBox.shrink();

          final isSelected = option.optionId?.toString() == selectedOptionId;

          return InkWell(
            onTap: () {
              if (option.optionId != null) {
                provider.setAnswer(
                  widget.question.questionId.toString(),
                  optionId: option.optionId.toString(),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.optionValue ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParentChild() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.question.childQuestions?.isNotEmpty ?? false) ...[
          const SizedBox(height: 24),
          ...widget.question.childQuestions?.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: QuestionWidget(
                    isChild: true,
                    index: entry.key + 1, // Adding 1 to make it 1-based index
                    question: entry.value,
                  ),
                );
              }).toList() ??
              []
        ],
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
