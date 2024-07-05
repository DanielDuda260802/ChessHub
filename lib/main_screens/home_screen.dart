import 'dart:math';

import 'package:bishop/bishop.dart' as bishop;
import 'package:chesshub/service/assetsManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('ChessHub', style: TextStyle(color: Colors.white)),
        ),
        body: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          children: [
            buildGameType(
                label: 'Play vs Computer', icon: Icons.computer, onTap: () {}),
            buildGameType(
                label: 'Play vs Friends', icon: Icons.person, onTap: () {}),
            buildGameType(
                label: 'Settings', icon: Icons.settings, onTap: () {}),
            buildGameType(label: 'About', icon: Icons.info, onTap: () {}),
          ],
        ));
  }
}

Widget buildGameType(
    {required String label,
    String? gameTime,
    IconData? icon,
    required Function() onTap}) {
  return InkWell(
    onTap: onTap,
    child: Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null ? Icon(icon) : Text(gameTime!),
          const SizedBox(
            height: 15,
          ),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold))
        ],
      ),
    ),
  );
}
