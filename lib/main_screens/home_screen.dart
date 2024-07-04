import 'dart:math';

import 'package:bishop/bishop.dart' as bishop;
import 'package:chesshub/service/assetsManager.dart';
import 'package:flutter/material.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bishop.Game game;
  late SquaresState state;
  int player = Squares.white;
  bool aiThinking = false;
  bool flipBoard = false;

  @override
  void initState() {
    // briše se ploča i postavlja u početnu poziciju
    _resetGame(false);
    super.initState();
  }

  void _resetGame([bool ss = true]) {
    // briše se ploča i postavlja u početnu poziciju
    game = bishop.Game(
        variant: bishop.Variant.standard()); // postavljen standard chess
    state = game.squaresState(player); // player 0 == WHITE , player 1 == BLACK
    if (ss) setState(() {});
  }

  void _flipBoard() => setState(() => flipBoard = !flipBoard);

  void _onMove(Move move) async {
    // makeSquaresMove ako je rezultat True potez je moguć, ako je false nije moguć potez
    // ako je moguć mijenja se stanje na ploči (state) i na potezu je sada crni (squaresState(player) --> jer je napravljano na način da smo mi uvijek bijeli)
    bool result = game.makeSquaresMove(move);
    if (result) {
      setState(() => state = game.squaresState(player));
    }
    // ako je kompjuter na potezu (aiThinking je različit od false, postavlja se true i on počinje razmišljati definirano vrijeme i igra svoj random potez te opet na red dolazi bijeli)
    if (state.state == PlayState.theirTurn && !aiThinking) {
      setState(() => aiThinking = true);
      await Future.delayed(
          Duration(milliseconds: Random().nextInt(4750) + 250));
      game.makeRandomMove();
      setState(() {
        aiThinking = false;
        state = game.squaresState(player);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: _resetGame,
              icon: const Icon(Icons.start, color: Colors.white),
            ),
            IconButton(
              onPressed: _flipBoard,
              icon: const Icon(Icons.rotate_left, color: Colors.white),
            ),
          ]),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double boardSize =
              min(constraints.maxWidth, constraints.maxHeight) * 0.8;

          return Center(
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Column(
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
                        trailing: const Text('05:00'),
                      ),
                      Expanded(
                        child: Container(
                          width: boardSize,
                          padding: const EdgeInsets.all(4.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: BoardController(
                              state: flipBoard
                                  ? state.board.flipped()
                                  : state.board,
                              playState: state.state,
                              pieceSet: PieceSet.merida(),
                              theme: BoardTheme.brown,
                              moves: state.moves,
                              onMove: _onMove,
                              onPremove: _onMove,
                              markerTheme: MarkerTheme(
                                empty: MarkerTheme.dot,
                                piece: MarkerTheme.corners(),
                              ),
                              promotionBehaviour:
                                  PromotionBehaviour.autoPremove,
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
                        trailing: const Text('02:00'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
