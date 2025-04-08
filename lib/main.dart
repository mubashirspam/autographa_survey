import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'provider/provider.dart';
import 'provider/auth_provider.dart';
import 'router/app_router.dart';
import 'utils/api_helper.dart';
import 'config/environment_config.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize environment configuration
  // Read from dart-define or default to development
  final String envName = const String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );

  final env = envName == 'production'
      ? Environment.production
      : Environment.development;

  EnvironmentConfig.initialize(env: env);

  ApiHelper.initializeInterceptors();
  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AnswerOptionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuestionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // ChangeNotifierProvider(
        //   create: (_) => SurveyAnswerProvider(),
        // ),
      ],
      child: MaterialApp.router(
        title: 'Autographa Survey',
        debugShowCheckedModeBanner: EnvironmentConfig.isDevelopment(),
        theme: ThemeData(
          primaryColor: Color(0XffDEAAFF),
          canvasColor: Color(0XffF9FAFB),
          scaffoldBackgroundColor: Color(0XffF9FAFB),
          useMaterial3: true,
          brightness: Brightness.light,
          fontFamily: GoogleFonts.figtree().fontFamily,
        ),
        // Using the router configuration
        routeInformationProvider: appRouter.routeInformationProvider,
        routeInformationParser: appRouter.routeInformationParser,

        routerDelegate: appRouter.routerDelegate,
      ),
    );
  }
}
