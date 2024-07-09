import 'package:bishop/bishop.dart';
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
    final gameProvider = context.read<GameProvider>();
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
        body: Padding(
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
                      groupValue: playerColorGroup,
                      onChanged: (value) {
                        setState(() {
                          playerColorGroup = value!;
                        });
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
                            border: Border.all(width: 0.5, color: Colors.black),
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
                      groupValue: playerColorGroup,
                      onChanged: (value) {
                        setState(() {
                          playerColorGroup = value!;
                        });
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
                            border: Border.all(width: 0.5, color: Colors.black),
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
                        Padding(
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
                                groupValue: gameDifficultyGroup,
                                onChanged: (value) {
                                  setState(() {
                                    gameDifficultyGroup = value!;
                                  });
                                }),
                            const SizedBox(
                              width: 10,
                            ),
                            GameDifficultyRadioButton(
                                title: GameDifficulty.medium.name,
                                value: GameDifficulty.medium,
                                groupValue: gameDifficultyGroup,
                                onChanged: (value) {
                                  setState(() {
                                    gameDifficultyGroup = value!;
                                  });
                                }),
                            const SizedBox(
                              width: 10,
                            ),
                            GameDifficultyRadioButton(
                                title: GameDifficulty.hard.name,
                                value: GameDifficulty.hard,
                                groupValue: gameDifficultyGroup,
                                onChanged: (value) {
                                  setState(() {
                                    gameDifficultyGroup = value!;
                                  });
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
        ));
  }

  void playGame({required GameProvider gameProvider}) {
    if (widget.isCustomTime) {
      if (whiteTimeInMinutes <= 0 && blackTimeInMinutes <= 0) {
        showSnackBar(context: context, content: 'Time cannot be 0.');
        return;
      }
    }

    // 1. Pokratanje loading dialoga
    gameProvider.setIsLoading(value: true);

    // 2. Spremanje vremena i boje figura za oba igrača

    // 3. Navigiranje na game screen
    Navigator.pushNamed(context, Constants.gameScreen);
  }
}
