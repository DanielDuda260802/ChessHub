import 'dart:math';

import 'package:bishop/bishop.dart' as bishop;
import 'package:chesshub/constants.dart';
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/main_screens/game_tempo_screen.dart';
import 'package:chesshub/providers/authentication_provider.dart';
import 'package:chesshub/providers/game_provider.dart';
import 'package:chesshub/service/assetsManager.dart';
import 'package:flutter/material.dart';
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
    final userModel = context.watch<AuthenticationProvider>().userModel;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('ChessHub', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              onPressed: () {
                context
                    .read<AuthenticationProvider>()
                    .signOut()
                    .whenComplete(() {
                  Navigator.pushNamedAndRemoveUntil(
                      context, Constants.loginScreen, (route) => false);
                });
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome ${userModel!.name}!',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(
                  height: 30,
                ),
                buildGameType(
                  label: 'Play Online',
                  icon: Icons.computer,
                  onTap: () {
                    gameProvider.setVsComputer(value: true);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GameTempoScreen()));
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                buildGameType(
                  label: 'Play vs Friends',
                  icon: Icons.person,
                  onTap: () {
                    gameProvider.setVsComputer(value: false);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GameTempoScreen()));
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
