import 'package:chesshub/constants.dart';
import 'package:chesshub/widgets/widgets.dart';
import 'package:flutter/material.dart';

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

  int whiteTimeInMinutes = 0;
  int blackTimeInMinutes = 0;

  @override
  Widget build(BuildContext context) {
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
            ],
          ),
        ));
  }
}
