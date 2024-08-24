import 'dart:async';
import 'dart:math';
import 'package:chesshub/constants.dart';
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/helper/uci_commands.dart';
import 'package:chesshub/models/user.dart';
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

                    gameProvider.setPlayBlacksTimer(value: false);
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
      gameProvider.setSquaresState().whenComplete(() async {
        if (gameProvider.player == Squares.white) {
          if (gameProvider.vsComputer) {
            gameProvider.pauseWhiteTimer();

            startTimer(
              isWhiteTimer: false,
              newGame: () {},
            );

            gameProvider.setPlayWhitesTimer(value: true);
          } else {
            // play online
            // play and save whites move to firestore
            await gameProvider.playMoveAndSaveToFirestore(
              context: context,
              move: move,
              isWhitesMove: true,
            );
          }
        } else {
          if (gameProvider.vsComputer) {
            gameProvider.pauseBlackTimer();

            startTimer(
              isWhiteTimer: true,
              newGame: () {},
            );
            gameProvider.setPlayBlacksTimer(value: true);
          } else {
            // play online
            // play and save blacks move to firestore
            await gameProvider.playMoveAndSaveToFirestore(
              context: context,
              move: move,
              isWhitesMove: false,
            );
          }
        }
      });
    }
    if (gameProvider.vsComputer) {
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
    }
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
    final userModel = context.read<AuthenticationProvider>().userModel;

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                bool? leave = await _showExitConfirmDialog(context);
                if (leave != null && leave) {
                  stockfish.stdin = UCICommands.stop;
                  await Future.delayed(const Duration(milliseconds: 200))
                      .whenComplete(() {
                    Navigator.pushNamedAndRemoveUntil(
                        context, Constants.homeScreen, (route) => false);
                  });
                }
              },
            ),
            actions: [
              const SizedBox(height: 16),
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
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    showOppenentsData(
                      gameProvider: gameProvider,
                      userModel: userModel!,
                      timeToShow: blackTimer,
                    ),
                    gameProvider.vsComputer
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
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
                              promotionBehaviour:
                                  PromotionBehaviour.autoPremove,
                            ),
                          )
                        : buildChessBoard(
                            gameProvider: gameProvider, userModel: userModel),
                    ListTile(
                      leading: userModel.image == ''
                          ? CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  AssetImage(AssetsManager.user_image),
                            )
                          : CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(userModel.image),
                            ),
                      title: Text(userModel.name),
                      subtitle: Text('Rating: ${userModel.playerRating}'),
                      trailing: Text(
                        whiteTimer,
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget buildChessBoard({
    required GameProvider gameProvider,
    required UserModel userModel,
  }) {
    bool isOurTurn = gameProvider.isWhitesTurn ==
        (gameProvider.gameCreatorUid == userModel.uid);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: BoardController(
        state: gameProvider.flipBoard
            ? gameProvider.state.board.flipped()
            : gameProvider.state.board,
        playState: isOurTurn ? PlayState.ourTurn : PlayState.theirTurn,
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
    );
  }

  Widget showOppenentsData({
    required GameProvider gameProvider,
    required UserModel userModel,
    required String timeToShow,
  }) {
    if (gameProvider.vsComputer) {
      return ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(AssetsManager.chessEngine_image),
        ),
        title: const Text('Stockfish'),
        subtitle: Text('Rating: ${gameProvider.gameLevel * 1000}'),
        trailing: Text(
          timeToShow,
          style: const TextStyle(fontSize: 18),
        ),
      );
    } else {
      // check is we are the creator of this game
      if (gameProvider.gameCreatorUid == userModel.uid) {
        return ListTile(
          leading: gameProvider.userPhoto == ''
              ? CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(AssetsManager.user_image),
                )
              : CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(gameProvider.userPhoto),
                ),
          title: Text(gameProvider.userName),
          subtitle: Text('Rating: ${gameProvider.userRating}'),
          trailing: Text(
            timeToShow,
            style: const TextStyle(fontSize: 18),
          ),
        );
      } else {
        return ListTile(
          leading: gameProvider.gameCreatorPhoto == ''
              ? CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(AssetsManager.user_image),
                )
              : CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(gameProvider.gameCreatorPhoto),
                ),
          title: Text(gameProvider.gameCreatorName),
          subtitle: Text('Rating: ${gameProvider.gameCreatorRating}'),
          trailing: Text(
            timeToShow,
            style: const TextStyle(fontSize: 18),
          ),
        );
      }
    }
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
