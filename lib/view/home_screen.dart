import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../provider/auth_provider.dart';
import '../provider/home_provider.dart';
import '../provider/provider.dart';
import 'widgets/list_item_card.dart';
import 'widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HomeProvider>();
      provider.fetchAllSurveysByUserId();
    });
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
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              // popup profile menu
              _showProfileMenu(context);
            },
          )
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
                      provider.fetchAllSurveysByUserId();
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
                                        provider.fetchAllSurveysByUserId();
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
                                          isSelected: false);
                                    },
                                  )
                                : const SizedBox(),
                  );
                },
              ),
            );
          }
          return const SizedBox();

          // return SafeArea(
          //   child: Row(
          //     children: [
          //       SizedBox(
          //         width: 400,
          //         child: _buildContainer(
          //           Consumer<HomeProvider>(
          //             builder: (context, provider, child) {
          //               return RefreshIndicator(
          //                 onRefresh: () async {
          //                   provider.fetchAllSurveysByUserId();
          //                   return;
          //                 },
          //                 child: provider.surveyList.isLoading &&
          //                         provider.surveyList.data?.isEmpty == true
          //                     ? const ShimmerLoading()
          //                     : provider.surveyList.isError ||
          //                             provider.surveyList.data?.isEmpty == true
          //                         ? Center(
          //                             child: Column(
          //                               mainAxisAlignment:
          //                                   MainAxisAlignment.center,
          //                               children: [
          //                                 Text(provider.surveyList.error ??
          //                                     'Error fetching surveys'),
          //                                 const SizedBox(height: 16),
          //                                 ElevatedButton(
          //                                   onPressed: () {
          //                                     provider
          //                                         .fetchAllSurveysByUserId();
          //                                   },
          //                                   child: const Text('Retry'),
          //                                 ),
          //                               ],
          //                             ),
          //                           )
          //                         : provider.surveyList.isSuccess &&
          //                                 provider.surveyList.data!.isNotEmpty
          //                             ? ListView.builder(
          //                                 // padding: const EdgeInsets.all(10),
          //                                 itemCount:
          //                                     provider.surveyList.data!.length,
          //                                 itemBuilder: (context, index) {
          //                                   return Padding(
          //                                     padding: const EdgeInsets.only(
          //                                         bottom: 8),
          //                                     child: ListItemCard(
          //                                       isDesktop: true,
          //                                       index: index,
          //                                       surveyData: provider
          //                                           .surveyList.data![index],
          //                                       isSelected: provider
          //                                               .selectedResponse?.id ==
          //                                           provider.surveyList
          //                                               .data![index].id,
          //                                     ),
          //                                   );
          //                                 },
          //                               )
          //                             : const SizedBox(),
          //               );
          //             },
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         flex: 3,
          //         child: Consumer<QuestionProvider>(
          //           builder: (context, surveyProvider, child) {
          //             if (surveyProvider.questionResponse.isLoading) {
          //               return const Center(child: CircularProgressIndicator());
          //             }
          //             if (surveyProvider.questionResponse.isError) {
          //               return Center(
          //                   child: Text(surveyProvider.questionResponse.error ??
          //                       " Something went wrong"));
          //             }
          //             if (surveyProvider.questionResponse.isSuccess &&
          //                 surveyProvider.questionList.isNotEmpty) {
          //               return Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   _buildContainer(
          //                     padding: EdgeInsets.all(0),
          //                     margin: EdgeInsets.all(10)
          //                         .copyWith(left: 0, bottom: 0),
          //                     Row(
          //                       children: [
          //                         SizedBox(width: 16),
          //                         Expanded(
          //                           flex: 3,
          //                           child: buildHeaderText(
          //                               surveyProvider.currentQuestionIndex + 1,
          //                               surveyProvider.questionList.length),
          //                         ),
          //                         const SizedBox(width: 20),
          //                         Expanded(
          //                           flex: 1,
          //                           child: BottomAppbarWidget(
          //                               responseId: response.id),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                   Expanded(
          //                     child: _buildContainer(
          //                       margin: EdgeInsets.all(10).copyWith(left: 0),
          //                       QuestionWidget(
          //                         question: surveyProvider.questionList[
          //                             surveyProvider.currentQuestionIndex],
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               );
          //             }
          //             return const Center(
          //                 child: Text("Please select a survey"));
          //           },
          //         ),
          //       ),
          //     ],
          //   ),
          // );
        },
      ),
    );
  }

  void _showProfileMenu(BuildContext context) async {
    // Get the auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Fetch user data
    await authProvider.getUserData();

    // Get user from provider
    final user = authProvider.userResponse.data;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile header with avatar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    child: Text(
                      user?.name?.isNotEmpty == true
                          ? user!.name![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Unknown User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? 'No Email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // User information fields
            _buildProfileInfoTile(
              Icons.email,
              'Email',
              user?.email ?? 'Not available',
            ),
            _buildProfileInfoTile(
              Icons.person,
              'Person ID',
              user?.personId?.toString() ?? 'Not available',
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit profile screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit profile coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context); // Close bottom sheet

                // Logout user
                await authProvider.logout();

                // Show logout toast notification
                authProvider.showLogoutToast(context);

                // Navigate to login screen using GoRouter
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value),
      dense: true,
    );
  }

  Widget _buildContainer(Widget child,
      {EdgeInsets? margin, EdgeInsets? padding, double? width}) {
    return Container(
      width: width,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
