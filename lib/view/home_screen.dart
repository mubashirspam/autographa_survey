import 'package:autographa_survey/view/widgets/header_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import '../provider/home_provider.dart';
import '../provider/survey_provider.dart';
import 'widgets/bottom_appbar_widget.dart';
import 'widgets/list_item_card.dart';
import 'widgets/question_widget.dart';
import 'widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().fetchAllSurveys(isRefresh: false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset('assets/icons/menu.svg'),
              onPressed: () {},
            );
          },
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
          if (constraints.maxWidth < 700) {
            return SafeArea(
              child: Consumer<HomeProvider>(
                builder: (context, provider, child) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await provider.fetchAllSurveys(isRefresh: true);
                    },
                    child: provider.surveyList.isLoading
                        ? const ShimmerLoading()
                        : provider.surveyList.isError ||
                                provider.surveyList.data?.isEmpty == true
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(provider.surveyList.error ??
                                        'Error fetching surveys'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        provider.fetchAllSurveys(
                                            isRefresh: true);
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : provider.surveyList.isSuccess &&
                                    provider.surveyList.data!.isNotEmpty
                                ? ListView.builder(
                                    padding: const EdgeInsets.all(10),
                                    itemCount: provider.surveyList.data!.length,
                                    itemBuilder: (context, index) {
                                      return ListItemCard(
                                        isDesktop: false,
                                        index: index,
                                        surveyData:
                                            provider.surveyList.data![index],
                                        isSelected: provider
                                                .selectedResponse?.id ==
                                            provider.surveyList.data![index].id,
                                      );
                                    },
                                  )
                                : const SizedBox(),
                  );
                },
              ),
            );
          }

          return SafeArea(
            child: Row(
              children: [
                SizedBox(
                  width: 400,
                  child: _buildContainer(
                    Consumer<HomeProvider>(
                      builder: (context, provider, child) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            await provider.fetchAllSurveys(isRefresh: true);
                            return;
                          },
                          child: provider.surveyList.isLoading &&
                                  provider.surveyList.data?.isEmpty == true
                              ? const ShimmerLoading()
                              : provider.surveyList.isError ||
                                      provider.surveyList.data?.isEmpty == true
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(provider.surveyList.error ??
                                              'Error fetching surveys'),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              provider.fetchAllSurveys(
                                                  isRefresh: true);
                                            },
                                            child: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : provider.surveyList.isSuccess &&
                                          provider.surveyList.data!.isNotEmpty
                                      ? ListView.builder(
                                          // padding: const EdgeInsets.all(10),
                                          itemCount:
                                              provider.surveyList.data!.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: ListItemCard(
                                                isDesktop: true,
                                                index: index,
                                                surveyData: provider
                                                    .surveyList.data![index],
                                                isSelected: provider
                                                        .selectedResponse?.id ==
                                                    provider.surveyList
                                                        .data![index].id,
                                              ),
                                            );
                                          },
                                        )
                                      : const SizedBox(),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Consumer<SurveyProvider>(
                    builder: (context, surveyProvider, child) {
                      final response =
                          context.read<HomeProvider>().selectedResponse;
                      if (surveyProvider.questionResponse.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (surveyProvider.questionResponse.isError) {
                        return Center(
                            child: Text(surveyProvider.questionResponse.error ??
                                " Something went wrong"));
                      }
                      if (surveyProvider.questionResponse.isSuccess &&
                          surveyProvider.questionList.isNotEmpty &&
                          response != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContainer(
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.all(10)
                                  .copyWith(left: 0, bottom: 0),
                              Row(
                                children: [
                                  SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: buildHeaderText(
                                        surveyProvider.currentQuestionIndex + 1,
                                        surveyProvider.questionList.length),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 1,
                                    child:
                                        BottomAppbarWidget(response: response),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _buildContainer(
                                margin: EdgeInsets.all(10).copyWith(left: 0),
                                QuestionWidget(
                                  question: surveyProvider.questionList[
                                      surveyProvider.currentQuestionIndex],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(
                          child: Text("Please select a survey"));
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

  Widget _buildContainer(Widget child,
      {EdgeInsets? margin, EdgeInsets? padding, double? width}) {
    return Container(
      width: width,
      padding: padding ?? const EdgeInsets.all(15),
      margin: margin ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}
