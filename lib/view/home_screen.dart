import 'package:autographa_survey/view/widgets/header_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import '../provider/home_provider.dart';
import '../provider/survey_provider.dart';
import '../provider/utils.dart';
import 'widgets/bottom_appbar_widget.dart';
import 'widgets/list_item_card.dart';
import 'widgets/question_widget.dart';
import 'widgets/shimmer_loading.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HomeProvider>(context, listen: false);
      provider.getSurveyList();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/menu.svg'),
          onPressed: () {},
        ),
        title: const Text(
          'Autographa Surveys',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1000) {
            return SafeArea(
              child: Consumer<HomeProvider>(
                builder: (context, provider, child) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      provider.resetError();
                      await provider.getSurveyList();
                    },
                    child: provider.state == LoadingState.loading &&
                            provider.surveyList.isEmpty
                        ? const ShimmerLoading()
                        : provider.state == LoadingState.error &&
                                provider.surveyList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(provider.error ??
                                        'Error fetching surveys'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        provider.resetError();
                                        provider.getSurveyList();
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(10),
                                itemCount: provider.surveyList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ListItemCard(
                                      index: index,
                                      surveyData: provider.surveyList[index],
                                    ),
                                  );
                                },
                              ),
                  );
                },
              ),
            );
          }
          return SafeArea(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    child: Consumer<HomeProvider>(
                      builder: (context, provider, child) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            provider.resetError();
                            await provider.getSurveyList();
                          },
                          child: provider.state == LoadingState.loading &&
                                  provider.surveyList.isEmpty
                              ? const ShimmerLoading()
                              : provider.state == LoadingState.error &&
                                      provider.surveyList.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(provider.error ??
                                              'Error fetching surveys'),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              provider.resetError();
                                              provider.getSurveyList();
                                            },
                                            child: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(10),
                                      itemCount: provider.surveyList.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: ListItemCard(
                                            index: index,
                                            surveyData:
                                                provider.surveyList[index],
                                          ),
                                        );
                                      },
                                    ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Consumer<SurveyProvider>(
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
                              _buildContainer(
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: buildHeaderText(
                                          surveyProvider.currentQuestionIndex +
                                              1,
                                          surveyProvider
                                              .surveyQuestionsList.length),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      flex: 1,
                                      child: BottomAppbarWidget(
                                        surveyId: surveyProvider
                                            .surveyQuestionsList[surveyProvider
                                                .currentQuestionIndex]
                                            .surveyId
                                            .toString(),
                                        userId: '1',
                                      ),
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
                      return const Center(
                          child: Text("No questions available"));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}
