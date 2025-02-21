import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import '../provider/home_provider.dart';
import '../provider/utils.dart';
import 'widgets/list_item_card.dart';
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
          'Surveys',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
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
                              Text(provider.error ?? 'Error fetching surveys'),
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
      ),
    );
  }
}
