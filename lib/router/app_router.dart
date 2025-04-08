import 'package:autographa_survey/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view/home_screen.dart';
import '../view/login_screen.dart';
import '../view/question_screens.dart';

class ScreenPaths {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  static String homeRouteByUserId(int userId) => '/home?userId=$userId';

  static String questionRoute(int? id) =>
      _appendToCurrentPath('survey?id=${id ?? ''}');

  static String _appendToCurrentPath(String newPath) {
    final newPathUri = Uri.parse(newPath);
    final currentUri = appRouter.routeInformationProvider.value.uri;
    Map<String, dynamic> params = Map.of(currentUri.queryParameters);
    params.addAll(newPathUri.queryParameters);
    Uri? loc = Uri(
        path: '${currentUri.path}/${newPathUri.path}'.replaceAll('//', '/'),
        queryParameters: params);
    return loc.toString();
  }
}

final appRouter = GoRouter(
  initialLocation: ScreenPaths.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: ScreenPaths.splash,
      redirect: (_, __) => ScreenPaths.login,
    ),
    GoRoute(
      path: ScreenPaths.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: ScreenPaths.home,
      name: 'home',
      builder: (context, state) {
        return HomeScreen();
      },
      routes: [
        GoRoute(
          path: 'survey',
          name: 'home_survey',
          builder: (context, state) {
            final surveyId =
                int.tryParse(state.uri.queryParameters['id'] ?? '');
            if (surveyId == null || surveyId == 0) {
              return const PageNotFound();
            }
            return QuestionScreen(responseId: surveyId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/survey',
      name: 'survey',
      builder: (context, state) {
        final surveyId = int.tryParse(state.uri.queryParameters['id'] ?? '');
        if (surveyId == null || surveyId == 0) {
          return const PageNotFound();
        }
        return QuestionScreen(responseId: surveyId);
      },
    ),
  ],
  errorBuilder: (context, state) => const PageNotFound(),
  redirect: handleRedirect,
);

GoRoute homeRoute([List<RouteBase> routes = const []]) => GoRoute(
      path: ScreenPaths.home,
      name: 'home',
      builder: (context, state) {
        return const HomeScreen();
      },
      routes: routes,
    );

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(ScreenPaths.login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

String? get initialDeeplink => _initialDeeplink;
String? _initialDeeplink;

Future<String?> handleRedirect(
    BuildContext context, GoRouterState state) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  await authProvider.initAuthState();
  final bool isUserSignedIn = authProvider.isAuthenticated;
  debugPrint('isUserSignedIn: $isUserSignedIn');
  debugPrint('state.uri.path: ${state.uri.path}');

  if (state.uri.path != ScreenPaths.login && !isUserSignedIn) {
    debugPrint('Redirecting from ${state.uri.path} to ${ScreenPaths.login}.');
    _initialDeeplink ??= state.uri.toString();
    return ScreenPaths.login;
  }

  if (isUserSignedIn &&
      (state.uri.path == ScreenPaths.login ||
          state.uri.path == ScreenPaths.splash)) {
    debugPrint('Redirecting from ${state.uri.path} to ${ScreenPaths.home}');
    return ScreenPaths.home;
  }

  return null; 
}
