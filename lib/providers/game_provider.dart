import 'package:chesshub/constants.dart';
import 'package:flutter/material.dart';
import 'package:squares/squares.dart';

class GameProvider extends ChangeNotifier {
  bool _vsComputer = false;
  bool _isLoading = false;

  int _player = Squares.white;
  PlayerColor _playerColor = PlayerColor.white;

  Duration _whiteTime = Duration.zero;
  Duration _blackTime = Duration.zero;

  Duration _whiteSavedTime = Duration.zero;
  Duration _blackSavedTime = Duration.zero;

  int get player => _player;
  PlayerColor get playerColor => _playerColor;

  Duration get whiteTime => _whiteTime;
  Duration get blackTime => _blackTime;
  Duration get whiteSavedTime => _whiteSavedTime;
  Duration get blackSavedTime => _blackSavedTime;

  bool get vsComputer => _vsComputer;
  bool get isLoading => _isLoading;

  void setVsComputer({required bool value}) {
    _vsComputer = value;
    notifyListeners();
  }

  void setIsLoading({required bool value}) {
    _isLoading = value;
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
}
