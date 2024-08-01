import 'dart:ui';

import 'package:chesshub/constants.dart';
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/main_screens/game_start_screen.dart';
import 'package:chesshub/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class GameTempoScreen extends StatefulWidget {
  const GameTempoScreen({super.key});

  @override
  State<GameTempoScreen> createState() => _GameTempoScreenState();
}

class _GameTempoScreenState extends State<GameTempoScreen> {
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final crossAxisCount =
        screenWidth > 600 ? 4 : 2; // Prilagodba broja stupaca

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Choose game tempo',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2, // Povećanje aspect ratio za bolje poravnanje
          ),
          itemCount: gameTempos.length,
          itemBuilder: (context, index) {
            final String label = gameTempos[index].split(' ')[0];
            final String tempo = gameTempos[index].split(' ')[1];

            return buildGameType(
              label: label,
              gameTime: tempo,
              onTap: () {
                if (label == Constants.custom) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameStartScreen(
                        isCustomTime: true,
                        gameTime: tempo,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameStartScreen(
                        isCustomTime: false,
                        gameTime: tempo,
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildGameType({
    required String label,
    required String gameTime,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                gameTime,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
