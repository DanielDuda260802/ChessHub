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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title:
              const Text('Setup Game', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: PlayerColorRadioButton(
                          title: 'Play as ${PlayerColor.white.name}',
                          value: PlayerColor.white,
                          groupValue: gameProvider.playerColor,
                          onChanged: (value) {
                            gameProvider.setPlayerColor(player: 0);
                          },
                        ),
                      ),
                      widget.isCustomTime
                          ? BuildCustomTime(
                              time: whiteTimeInMinutes.toString(),
                              onLeftArrowClicked: () {
                                setState(() {
                                  whiteTimeInMinutes--;
                                });
                              },
                              onRightArrowClicked: () {
                                setState(() {
                                  whiteTimeInMinutes++;
                                });
                              })
                          : Container(
                              height: 60,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.5, color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    widget.gameTime,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 25, color: Colors.black),
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: PlayerColorRadioButton(
                          title: 'Play as ${PlayerColor.black.name}',
                          value: PlayerColor.black,
                          groupValue: gameProvider.playerColor,
                          onChanged: (value) {
                            gameProvider.setPlayerColor(player: 1);
                          },
                        ),
                      ),
                      widget.isCustomTime
                          ? BuildCustomTime(
                              time: blackTimeInMinutes.toString(),
                              onLeftArrowClicked: () {
                                setState(() {
                                  blackTimeInMinutes--;
                                });
                              },
                              onRightArrowClicked: () {
                                setState(() {
                                  blackTimeInMinutes++;
                                });
                              })
                          : Container(
                              height: 60,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.5, color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    widget.gameTime,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 25, color: Colors.black),
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                  gameProvider.vsComputer
                      ? Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'Game difficult',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GameDifficultyRadioButton(
                                    title: GameDifficulty.easy.name,
                                    value: GameDifficulty.easy,
                                    groupValue: gameProvider.gameDifficulty,
                                    onChanged: (value) {
                                      gameProvider.setGameDifficulty(level: 1);
                                    }),
                                const SizedBox(
                                  width: 10,
                                ),
                                GameDifficultyRadioButton(
                                    title: GameDifficulty.medium.name,
                                    value: GameDifficulty.medium,
                                    groupValue: gameProvider.gameDifficulty,
                                    onChanged: (value) {
                                      gameProvider.setGameDifficulty(level: 2);
                                    }),
                                const SizedBox(
                                  width: 10,
                                ),
                                GameDifficultyRadioButton(
                                    title: GameDifficulty.hard.name,
                                    value: GameDifficulty.hard,
                                    groupValue: gameProvider.gameDifficulty,
                                    onChanged: (value) {
                                      gameProvider.setGameDifficulty(level: 3);
                                    }),
                              ],
                            )
                          ],
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        playGame(gameProvider: gameProvider);
                      },
                      child: Text('play'))
                ],
              ),
            );
          },
        ));
  }

  void playGame({required GameProvider gameProvider}) async {
    if (widget.isCustomTime) {
      if (whiteTimeInMinutes <= 0 || blackTimeInMinutes <= 0) {
        showSnackBar(context: context, content: 'Time cannot be 0.');
        return;
      }
      // 1. Pokratanje loading dialoga
      gameProvider.setIsLoading(value: true);

      // 2. Spremanje vremena i boje figura za oba igrača
      await gameProvider
          .setGameTime(
        newWhiteSavedTime: whiteTimeInMinutes.toString(),
        newBlackSavedTime: blackTimeInMinutes.toString(),
      )
          .whenComplete(() {
        if (gameProvider.vsComputer) {
          gameProvider.setIsLoading(value: false);
        } else {
          // search for players
        }
      });
      // 3. Navigiranje na game screen
      Navigator.pushNamed(context, Constants.gameScreen);
    } else {
      // not custom tempo
      // provjera postoji li dodatak po potezu (vrijednost nakon "+")
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
