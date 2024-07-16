import 'dart:async';
import 'dart:io';
import 'package:bishop/bishop.dart' as bishop;
import 'package:chesshub/constants.dart';
import 'package:chesshub/helper/uci_commands.dart';
import 'package:chesshub/main_screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';

class GameProvider extends ChangeNotifier {
  // inicijalizacija varijabli
  late bishop.Game _game = bishop.Game(variant: bishop.Variant.standard());
  late SquaresState _state = SquaresState.initial(0);

  bool _aiThinking = false;
  bool _flipBoard = false;

  bool _playWhitesTimer = false;
  bool _playBlacksTimer = false;

  bool _vsComputer = false;
  bool _isLoading = false;

  int _gameLevel = 1;
  int _increment = 0;
  int _player = Squares.white;
  PlayerColor _playerColor = PlayerColor.white;
  GameDifficulty _gameDifficulty = GameDifficulty.easy;

  Duration _whiteTime = Duration.zero;
  Duration _blackTime = Duration.zero;

  Duration _whiteSavedTime = Duration.zero;
  Duration _blackSavedTime = Duration.zero;

  Timer? _whiteTimer;
  Timer? _blackTimer;

  int _whitesScore = 0;
  int _blacksScore = 0;

  // get metode
  bishop.Game get game => _game;
  SquaresState get state => _state;
  bool get aiThinking => _aiThinking;
  bool get flipBoard => _flipBoard;
  bool get playWhitesTimer => _playWhitesTimer;
  bool get playBlacksTimer => _playBlacksTimer;

  int get gameLevel => _gameLevel;
  int get increment => _increment;
  int get player => _player;
  PlayerColor get playerColor => _playerColor;
  GameDifficulty get gameDifficulty => _gameDifficulty;

  Duration get whiteTime => _whiteTime;
  Duration get blackTime => _blackTime;
  Duration get whiteSavedTime => _whiteSavedTime;
  Duration get blackSavedTime => _blackSavedTime;

  bool get vsComputer => _vsComputer;
  bool get isLoading => _isLoading;

  Timer? get whiteTimer => _whiteTimer;
  Timer? get blackTimer => _blackTimer;

  int get whitesScore => _whitesScore;
  int get blacksScore => _blacksScore;

  // set metode
  void setVsComputer({required bool value}) {
    _vsComputer = value;
    notifyListeners();
  }

  void setIsLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  void setPlayWhitesTimer({required bool value}) {
    _playWhitesTimer = value;
    notifyListeners();
  }

  void setPlayBlacksTimer({required bool value}) {
    _playBlacksTimer = value;
    notifyListeners();
  }

  Future<void> setGameTime({
    required String newWhiteSavedTime,
    required String newBlackSavedTime,
  }) async {
    _whiteSavedTime = Duration(minutes: int.parse(newWhiteSavedTime));
    _blackSavedTime = Duration(minutes: int.parse(newBlackSavedTime));
    notifyListeners();

    setWhiteTime(_whiteSavedTime);
    setBlackime(_blackSavedTime);
  }

  void setWhiteTime(Duration time) {
    _whiteTime = time;
    notifyListeners();
  }

  void setBlackime(Duration time) {
    _blackTime = time;
    notifyListeners();
  }

  void setPlayerColor({required int player}) {
    _player = player;
    _playerColor =
        player == Squares.white ? PlayerColor.white : PlayerColor.black;
    notifyListeners();
  }

  void setGameDifficulty({required int level}) {
    _gameLevel = gameLevel;
    _gameDifficulty = level == 1
        ? GameDifficulty.easy
        : level == 2
            ? GameDifficulty.medium
            : GameDifficulty.hard;
    notifyListeners();
  }

  void setIncrement({required int increment}) {
    _increment = increment;
    notifyListeners();
  }

  void setAiThinking(bool value) {
    _aiThinking = value;
    notifyListeners();
  }

  Future<void> setSquaresState() async {
    _state = game.squaresState(player);
    notifyListeners();
  }

  // reset game metoda
  void resetGame({required bool newGame}) {
    if (newGame) {
      // provjera koja je boje figure imao igrač u prošloj partiji kako bismo mogli obrnuti
      if (_player == Squares.white) {
        _player = Squares.black;
      } else {
        _player = Squares.white;
      }
      notifyListeners();
    }
    _game = bishop.Game(variant: bishop.Variant.standard());
    _state = game.squaresState(_player);
  }

  bool makeSquaresMove(Move move) {
    bool result = game.makeSquaresMove(move);
    notifyListeners();
    return result;
  }

  void flipChessBoard() {
    _flipBoard = !_flipBoard;
    notifyListeners();
  }

  void startBlackTime({
    required BuildContext context,
    Process? stockfish,
    required Function newGame,
  }) {
    _blackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _blackTime = blackTime - const Duration(seconds: 1);
      notifyListeners();

      // pad zastavice!
      if (_blackTime <= Duration.zero) {
        _blackTimer!.cancel();
        notifyListeners();

        // GAME OVER
        if (context.mounted) {
          gameOverDialog(
            context: context,
            stockfish: stockfish,
            timeOut: true,
            whiteWon: true,
            newGame: newGame,
          );
        }
      }
    });
  }

  void startWhiteTime({
    required BuildContext context,
    Process? stockfish,
    required Function newGame,
  }) {
    _whiteTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _whiteTime = whiteTime - const Duration(seconds: 1);
      notifyListeners();

      // pad zastavice!
      if (_whiteTime <= Duration.zero) {
        _whiteTimer!.cancel();
        notifyListeners();

        // GAME OVER
        if (context.mounted) {
          gameOverDialog(
            context: context,
            stockfish: stockfish,
            timeOut: true,
            whiteWon: false,
            newGame: newGame,
          );
        }
      }
    });
  }

  void pauseWhiteTimer() {
    if (_whiteTimer != null) {
      _whiteTime += Duration(seconds: _increment);
      _whiteTimer!.cancel();
      notifyListeners();
    }
  }

  void pauseBlackTimer() {
    if (_blackTimer != null) {
      _blackTime += Duration(seconds: _increment);
      _blackTimer!.cancel();
      notifyListeners();
    }
  }

  void gameOverListerner({
    required BuildContext context,
    Process? stockfish,
    required Function newGame,
  }) {
    if (game.gameOver) {
      pauseWhiteTimer();
      pauseBlackTimer();

      // GAME OVER
      if (context.mounted) {
        gameOverDialog(
          context: context,
          stockfish: stockfish,
          timeOut: false,
          whiteWon: false,
          newGame: newGame,
        );
      }
    }
  }

  void gameOverDialog({
    required BuildContext context,
    Process? stockfish,
    required bool timeOut,
    required bool whiteWon,
    required Function newGame,
  }) {
    if (stockfish != null) {
      stockfish.stdin.writeln(UCICommands.stop);
    }

    String results = '';
    int whiteScore = 0;
    int blackScore = 0;

    if (timeOut) {
      if (whiteWon) {
        results = 'White won on time!';
        whiteScore = _whitesScore + 1;
      } else {
        results = 'Black won on time!';
        blackScore = _blacksScore + 1;
      }
    } else {
      results = game.result!.readable; // method from package

      if (game.drawn) {
        // method check if the game is a draw
        String whiteResult = game.result!.scoreString.split('-').first;
        String blackResult = game.result!.scoreString.split('-').last;
        whiteScore = _whitesScore += int.parse(whiteResult);
        blackScore = _blacksScore += int.parse(blackResult);
      } else if (game.winner == 0) {
        String whiteResult = game.result!.scoreString.split('-').first;
        whiteScore = _whitesScore += int.parse(whiteResult);
      } else if (game.winner == 1) {
        String blackResult = game.result!.scoreString.split('-').last;
        blackScore = _blacksScore += int.parse(blackResult);
      } else if (game.stalemate) {
        whiteScore = whitesScore;
        blackScore = blacksScore;
      }
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Game Over\n $whiteScore - $blackScore',
          textAlign: TextAlign.center,
        ),
        content: Text(
          results,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'New Game',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  getPositionFen() {
    return game.fen;
  }
}
