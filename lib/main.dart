import 'package:bishop/bishop.dart';
import 'package:chesshub/constants.dart';
import 'package:chesshub/main_screens/about_screen.dart';
import 'package:chesshub/main_screens/game_screen.dart';
import 'package:chesshub/main_screens/game_start_screen.dart';
import 'package:chesshub/main_screens/game_tempo_screen.dart';
import 'package:chesshub/main_screens/home_screen.dart';
import 'package:chesshub/main_screens/settings_screen.dart';
import 'package:chesshub/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
    )
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
      initialRoute: Constants.homeScreen,
      routes: {
        Constants.homeScreen: (context) => const HomeScreen(),
        Constants.gameScreen: (context) => const GameScreen(),
        Constants.settingScreen: (context) => const SettingsScreen(),
        Constants.aboutScreen: (context) => const AboutScreen(),
        Constants.gameTempoScreen: (context) => const GameTempoScreen(),
      },
    );
  }
}
