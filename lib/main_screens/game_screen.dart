import 'dart:async';
import 'dart:math';
import 'package:chesshub/constants.dart';
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/helper/uci_commands.dart';
import 'package:chesshub/providers/authentication_provider.dart';
import 'package:chesshub/providers/game_provider.dart';
import 'package:chesshub/service/assetsManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';
import 'package:stockfish/stockfish.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Stockfish stockfish;

  @override
  void initState() {
    stockfish = Stockfish();
    final gameProvider = context.read<GameProvider>();
    gameProvider.resetGame(newGame: false);

    if (mounted) {
      letOtherPlayerPlayFirst();
    }
    super.initState();
  }

  @override
  void dispose() {
    stockfish.dispose();
    super.dispose();
  }

  void letOtherPlayerPlayFirst() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameProvider = context.read<GameProvider>();

      if (gameProvider.vsComputer) {
        if (gameProvider.state.state == PlayState.theirTurn &&
            !gameProvider.aiThinking) {
          gameProvider.setAiThinking(true);

          // wait until stockfish is ready
          await waitUntilReady();

          // get the current position of the board and sent to stockfish
          stockfish.stdin =
              '${UCICommands.position} ${gameProvider.getPositionFen()}';

          // set stockfish difficulty level
          stockfish.stdin =
              '${UCICommands.goMoveTime} ${gameProvider.gameLevel * 1000}';

          stockfish.stdout.listen((event) {
            if (event.contains(UCICommands.bestMove)) {
              final bestMove = event.split(' ')[1];
              gameProvider.makeStringMove(bestMove);
              gameProvider.setAiThinking(false);
              gameProvider.setSquaresState().whenComplete(() {
                if (gameProvider.player == Squares.white) {
                  if (gameProvider.playWhitesTimer) {
                    gameProvider.pauseBlackTimer();

                    startTimer(
                      isWhiteTimer: true,
                      newGame: () {},
                    );

                    gameProvider.setPlayWhitesTimer(value: false);
                  }
                } else {
                  if (gameProvider.playBlacksTimer) {
                    gameProvider.pauseWhiteTimer();

                    startTimer(
                      isWhiteTimer: false,
                      newGame: () {},
                    );

                    gameProvider.setPlayBlacksTimer(value: true);
                  }
                }
              });
            }
          });
        }
      } else {
        final userModel = context.read<AuthenticationProvider>().userModel;
        //listen for game changes in firestore
        gameProvider.listenGameChangesFirestore(
            context: context, userModel: userModel!);
      }
    });
  }

  void checkGameOverListener() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.gameOverListerner(
      context: context,
      stockfish: stockfish,
      newGame: () {
        // start a new game
      },
    );
  }

  void _onMove(Move move) async {
    final gameProvider = context.read<GameProvider>();
    bool result = gameProvider.game.makeSquaresMove(move);
    if (result) {
      gameProvider.setSquaresState().whenComplete(() {
        if (gameProvider.player == Squares.white) {
          gameProvider.pauseWhiteTimer();

          startTimer(
            isWhiteTimer: false,
            newGame: () {},
          );

          gameProvider.setPlayWhitesTimer(value: true);
        } else {
          gameProvider.pauseBlackTimer();

          startTimer(
            isWhiteTimer: true,
            newGame: () {},
          );
          gameProvider.setPlayBlacksTimer(value: true);
        }
      });
    }
    if (gameProvider.state.state == PlayState.theirTurn &&
        !gameProvider.aiThinking) {
      gameProvider.setAiThinking(true);

      await waitUntilReady();

      stockfish.stdin =
          '${UCICommands.position} ${gameProvider.getPositionFen()}';

      stockfish.stdin =
          '${UCICommands.goMoveTime} ${gameProvider.gameLevel * 1000}';

      stockfish.stdout.listen((event) {
        if (event.contains(UCICommands.bestMove)) {
          final bestMove = event.split(' ')[1];
          gameProvider.makeStringMove(bestMove);
          gameProvider.setAiThinking(false);
          gameProvider.setSquaresState().whenComplete(() {
            if (gameProvider.player == Squares.white) {
              if (gameProvider.playWhitesTimer) {
                gameProvider.pauseBlackTimer();

                startTimer(
                  isWhiteTimer: true,
                  newGame: () {},
                );

                gameProvider.setPlayWhitesTimer(value: false);
              }
            } else {
              if (gameProvider.playBlacksTimer) {
                gameProvider.pauseWhiteTimer();

                startTimer(
                  isWhiteTimer: false,
                  newGame: () {},
                );

                gameProvider.setPlayBlacksTimer(value: false);
              }
            }
          });
        }
      });
    }
    await Future.delayed(const Duration(seconds: 1));
    checkGameOverListener();
  }

  Future<void> waitUntilReady() async {
    while (stockfish.state.value != StockfishState.ready) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void startTimer({
    required bool isWhiteTimer,
    required Function newGame,
  }) {
    final gameProvider = context.read<GameProvider>();
    if (isWhiteTimer == true) {
      gameProvider.startWhiteTime(
        context: context,
        stockfish: stockfish,
        newGame: newGame,
      );
    } else {
      gameProvider.startBlackTime(
        context: context,
        stockfish: stockfish,
        newGame: newGame,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();

    return WillPopScope(
      onWillPop: () async {
        bool? leave = await _showExitConfirmDialog(context);
        if (leave != null && leave) {
          stockfish.stdin = UCICommands.stop;
          await Future.delayed(const Duration(milliseconds: 200))
              .whenComplete(() {
            Navigator.pushNamedAndRemoveUntil(
                context, Constants.homeScreen, (route) => false);
          });
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            title:
                const Text('ChessHub', style: TextStyle(color: Colors.white)),
            actions: [
              const SizedBox(height: 16),
              IconButton(
                onPressed: () {
                  gameProvider.resetGame(newGame: false);
                },
                icon: const Icon(Icons.start, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  gameProvider.flipChessBoard();
                },
                icon: const Icon(Icons.rotate_left, color: Colors.white),
              ),
            ]),
        body: LayoutBuilder(
          builder: (context, constraints) {
            double boardSize =
                min(constraints.maxWidth, constraints.maxHeight) * 0.8;

            return Center(
              child: Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                String whiteTimer = getTimerToDisplay(
                  gameProvider: gameProvider,
                  isUser: true,
                );
                String blackTimer = getTimerToDisplay(
                  gameProvider: gameProvider,
                  isUser: false,
                );
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            AssetImage(AssetsManager.chessEngine_image),
                      ),
                      title: const Text('Stockfish'),
                      subtitle: const Text('Rating: 3000'),
                      trailing: Text(
                        blackTimer,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: boardSize,
                        padding: const EdgeInsets.all(4.0),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: BoardController(
                            state: gameProvider.flipBoard
                                ? gameProvider.state.board.flipped()
                                : gameProvider.state.board,
                            playState: gameProvider.state.state,
                            pieceSet: PieceSet.merida(),
                            theme: BoardTheme.brown,
                            moves: gameProvider.state.moves,
                            onMove: _onMove,
                            onPremove: _onMove,
                            markerTheme: MarkerTheme(
                              empty: MarkerTheme.dot,
                              piece: MarkerTheme.corners(),
                            ),
                            promotionBehaviour: PromotionBehaviour.autoPremove,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(AssetsManager.user_image),
                      ),
                      title: const Text('User_01'),
                      subtitle: const Text('Rating: 1200'),
                      trailing: Text(
                        whiteTimer,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Leave game?',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Are you sure to leave this game',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
