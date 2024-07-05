import 'dart:math';

import 'package:bishop/bishop.dart' as bishop;
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/main_screens/about_screen.dart';
import 'package:chesshub/main_screens/game_tempo_screen.dart';
import 'package:chesshub/main_screens/settings_screen.dart';
import 'package:chesshub/providers/game_provider.dart';
import 'package:chesshub/service/assetsManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('ChessHub', style: TextStyle(color: Colors.white)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            children: [
              buildGameType(
                  label: 'Play vs Computer',
                  icon: Icons.computer,
                  onTap: () {
                    gameProvider.setVsComputer(value: true);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GameTempoScreen()));
                  }),
              buildGameType(
                  label: 'Play vs Friends',
                  icon: Icons.person,
                  onTap: () {
                    gameProvider.setVsComputer(value: false);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GameTempoScreen()));
                  }),
              buildGameType(
                  label: 'Settings',
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()));
                  }),
              buildGameType(
                  label: 'About',
                  icon: Icons.info,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutScreen()));
                  }),
            ],
          ),
        ));
  }
}
