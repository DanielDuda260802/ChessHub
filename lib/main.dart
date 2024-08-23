import 'package:chesshub/authentication/login_screen.dart';
import 'package:chesshub/authentication/sign_up_screen.dart';
import 'package:chesshub/constants.dart';
import 'package:chesshub/firebase_options.dart';
import 'package:chesshub/main_screens/about_screen.dart';
import 'package:chesshub/main_screens/game_screen.dart';
import 'package:chesshub/main_screens/game_tempo_screen.dart';
import 'package:chesshub/main_screens/home_screen.dart';
import 'package:chesshub/main_screens/settings_screen.dart';
import 'package:chesshub/providers/authentication_provider.dart';
import 'package:chesshub/providers/game_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
    ),
    ChangeNotifierProvider(
      create: (_) => AuthenticationProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: Constants.loginScreen,
      routes: {
        Constants.homeScreen: (context) => const HomeScreen(),
        Constants.gameScreen: (context) => const GameScreen(),
        Constants.settingScreen: (context) => const SettingsScreen(),
        Constants.aboutScreen: (context) => const AboutScreen(),
        Constants.gameTempoScreen: (context) => const GameTempoScreen(),
        Constants.loginScreen: (context) => const LoginScreen(),
        Constants.signUpScreen: (context) => const SignUpScreen(),
      },
    );
  }
}
