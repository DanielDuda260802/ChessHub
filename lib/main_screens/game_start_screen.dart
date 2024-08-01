import 'package:chesshub/constants.dart';
import 'package:chesshub/providers/game_provider.dart';
import 'package:chesshub/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameStartScreen extends StatefulWidget {
  const GameStartScreen(
      {super.key, required this.isCustomTime, required this.gameTime});

  final bool isCustomTime;
  final String gameTime;

  @override
  State<GameStartScreen> createState() => _GameStartScreenState();
}

class _GameStartScreenState extends State<GameStartScreen> {
  PlayerColor playerColorGroup = PlayerColor.white;
  GameDifficulty gameDifficultyGroup = GameDifficulty.easy;

  int whiteTimeInMinutes = 0;
  int blackTimeInMinutes = 0;

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Setup Game', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildPlayerColorSelection(screenWidth, gameProvider),
              const SizedBox(height: 20), // Added space between sections
              _buildTimeSelection(screenWidth, gameProvider),
              const SizedBox(height: 20), // Added space between sections
              if (gameProvider.vsComputer)
                _buildGameDifficultySelection(screenWidth, gameProvider),
              const SizedBox(height: 20), // Added space before the button
              ElevatedButton(
                onPressed: () {
                  playGame(gameProvider: gameProvider);
                },
                child: const Text('Play'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.8, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerColorSelection(
      double screenWidth, GameProvider gameProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: PlayerColorRadioButton(
            title: 'Play as ${PlayerColor.white.name}',
            value: PlayerColor.white,
            groupValue: gameProvider.playerColor,
            onChanged: (value) {
              gameProvider.setPlayerColor(player: 0);
            },
          ),
        ),
        const SizedBox(
            width: 10), // Padding between player color and time control
        Flexible(
          flex: 1,
          child: widget.isCustomTime
              ? _buildCustomTimeControl(
                  whiteTimeInMinutes, gameProvider, PlayerColor.white)
              : _buildPresetTimeDisplay(widget.gameTime),
        ),
      ],
    );
  }

  Widget _buildTimeSelection(double screenWidth, GameProvider gameProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: PlayerColorRadioButton(
            title: 'Play as ${PlayerColor.black.name}',
            value: PlayerColor.black,
            groupValue: gameProvider.playerColor,
            onChanged: (value) {
              gameProvider.setPlayerColor(player: 1);
            },
          ),
        ),
        const SizedBox(
            width: 10), // Padding between player color and time control
        Flexible(
          flex: 1,
          child: widget.isCustomTime
              ? _buildCustomTimeControl(
                  blackTimeInMinutes, gameProvider, PlayerColor.black)
              : _buildPresetTimeDisplay(widget.gameTime),
        ),
      ],
    );
  }

  Widget _buildGameDifficultySelection(
      double screenWidth, GameProvider gameProvider) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Game difficulty',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GameDifficultyRadioButton(
                title: GameDifficulty.easy.name,
                value: GameDifficulty.easy,
                groupValue: gameProvider.gameDifficulty,
                onChanged: (value) {
                  gameProvider.setGameDifficulty(level: 1);
                },
              ),
            ),
            const SizedBox(width: 10), // Padding between difficulty buttons
            Expanded(
              child: GameDifficultyRadioButton(
                title: GameDifficulty.medium.name,
                value: GameDifficulty.medium,
                groupValue: gameProvider.gameDifficulty,
                onChanged: (value) {
                  gameProvider.setGameDifficulty(level: 2);
                },
              ),
            ),
            const SizedBox(width: 10), // Padding between difficulty buttons
            Expanded(
              child: GameDifficultyRadioButton(
                title: GameDifficulty.hard.name,
                value: GameDifficulty.hard,
                groupValue: gameProvider.gameDifficulty,
                onChanged: (value) {
                  gameProvider.setGameDifficulty(level: 3);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomTimeControl(
      int time, GameProvider gameProvider, PlayerColor color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              if (color == PlayerColor.white) {
                if (whiteTimeInMinutes > 0) whiteTimeInMinutes--;
              } else {
                if (blackTimeInMinutes > 0) blackTimeInMinutes--;
              }
            });
          },
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$time min'),
        IconButton(
          onPressed: () {
            setState(() {
              if (color == PlayerColor.white) {
                whiteTimeInMinutes++;
              } else {
                blackTimeInMinutes++;
              }
            });
          },
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildPresetTimeDisplay(String time) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            time,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      ),
    );
  }

  void playGame({required GameProvider gameProvider}) async {
    if (widget.isCustomTime) {
      if (whiteTimeInMinutes <= 0 || blackTimeInMinutes <= 0) {
        showSnackBar(context: context, content: 'Time cannot be 0.');
        return;
      }
      gameProvider.setIsLoading(value: true);

      await gameProvider
          .setGameTime(
        newWhiteSavedTime: whiteTimeInMinutes.toString(),
        newBlackSavedTime: blackTimeInMinutes.toString(),
      )
          .whenComplete(() {
        if (gameProvider.vsComputer) {
          gameProvider.setIsLoading(value: false);
          Navigator.pushNamed(context, Constants.gameScreen);
        } else {
          // search for players
        }
      });
    } else {
      final String incrementalTime = widget.gameTime.split('+')[1];
      final String gameTempo = widget.gameTime.split('+')[0];

      if (incrementalTime != '0') {
        gameProvider.setIncrement(increment: int.parse(incrementalTime));
      }

      gameProvider.setIsLoading(value: true);

      await gameProvider
          .setGameTime(
        newWhiteSavedTime: gameTempo,
        newBlackSavedTime: gameTempo,
      )
          .whenComplete(() {
        if (gameProvider.vsComputer) {
          gameProvider.setIsLoading(value: false);
          Navigator.pushNamed(context, Constants.gameScreen);
        } else {
          //search for players
        }
      });
    }
  }
}
