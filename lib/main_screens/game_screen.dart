import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bishop/bishop.dart' as bishop;
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/helper/uci_commands.dart';
import 'package:chesshub/providers/game_provider.dart';
import 'package:chesshub/service/assetsManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Process stockfish;
  late StreamSubscription<String> _stdoutSubscription;
  late StreamSubscription<String> _stderrSubscription;
  final List<String> _outputLines = [];
  Completer<void>? _readyCompleter;
  Completer<String>? _bestMoveCompleter;

  @override
  void initState() {
    super.initState();
    _startStockfish();
    final gameProvider = context.read<GameProvider>();
    gameProvider.resetGame(newGame: false);

    if (mounted) {
      letOtherPlayerPlayFirst();
    }
  }

  Future<void> _startStockfish() async {
    stockfish = await Process.start('/usr/local/bin/stockfish', []);
    _stdoutSubscription = stockfish.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((data) {
      _handleOutput(data);
    });

    _stderrSubscription = stockfish.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((data) {
      print('Error: $data');
    });

    // Send UCI command to initialize Stockfish
    _sendCommand('uci');
  }

  void _sendCommand(String command) {
    print('Sending command: $command');
    stockfish.stdin.writeln(command);
  }

  @override
  void dispose() {
    stockfish.kill();
    _stdoutSubscription.cancel();
    _stderrSubscription.cancel();
    super.dispose();
  }

  void _handleOutput(String data) {
    print('Stockfish output: $data');
    _outputLines.add(data);

    if (_readyCompleter != null && data.contains('uciok')) {
      _readyCompleter!.complete();
      _readyCompleter = null;
    }

    if (_bestMoveCompleter != null && data.contains(UCICommands.bestMove)) {
      final bestMove = data.split(' ')[1];
      print('Best move received: $bestMove');
      _bestMoveCompleter!.complete(bestMove);
      _bestMoveCompleter = null;
    }
  }

  Future<void> _waitForReady() {
    _readyCompleter = Completer<void>();
    return _readyCompleter!.future;
  }

  Future<String> _waitForBestMove() {
    _bestMoveCompleter = Completer<String>();
    return _bestMoveCompleter!.future;
  }

  void letOtherPlayerPlayFirst() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameProvider = context.read<GameProvider>();
      if (gameProvider.state.state == PlayState.theirTurn &&
          !gameProvider.aiThinking) {
        gameProvider.setAiThinking(true);
        await Future.delayed(
            Duration(milliseconds: Random().nextInt(4750) + 250));
        gameProvider.game.makeRandomMove();
        gameProvider.setAiThinking(false);
        gameProvider.setSquaresState().whenComplete(() {
          gameProvider.pauseWhiteTimer();

          startTimer(
            isWhiteTimer: false,
            newGame: () {},
          );
        });
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

      // get the current position of the board and send to stockfish
      _sendCommand('${UCICommands.position} ${gameProvider.getPositionFen()}');

      // set stockfish difficulty level
      _sendCommand(
          '${UCICommands.goMoveTime} ${gameProvider.gameLevel * 1000}');

      String bestMove = await _waitForBestMove();
      print('Best move from Stockfish: $bestMove');
      gameProvider.game.makeMoveString(bestMove);
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
    await Future.delayed(const Duration(seconds: 1));
    checkGameOverListener();
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
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Colors.black,
          title: const Text('ChessHub', style: TextStyle(color: Colors.white)),
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
            child:
                Consumer<GameProvider>(builder: (context, gameProvider, child) {
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
    );
  }
}
