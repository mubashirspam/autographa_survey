import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'provider/survey_provider.dart';
import 'view/home_screen.dart';
import 'provider/home_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SurveyProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Autographa Survey',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0XffDEAAFF),
          canvasColor: Color(0XffF9FAFB),
          scaffoldBackgroundColor: Color(0XffF9FAFB),
          useMaterial3: true,
          brightness: Brightness.light,
          fontFamily: GoogleFonts.figtree().fontFamily,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
