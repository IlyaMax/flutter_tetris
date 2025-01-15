import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tetris/game_storage.dart';

class GameModel extends ChangeNotifier {
  final GameStorage _gameStorage;
  GameModel(this._gameStorage);
  static const int _boardWidth = 12;
  static const int _boardHeight = 20;
  final Random _random = Random();

  static const _figures = [
    [
      [true, true],
      [true, true]
    ],
    [
      [true, true, true],
      [true, false, false],
    ],
    [
      [true, false, false],
      [true, true, true],
    ],
    [
      [true, true, true, true],
    ],
    [
      [false, true, true],
      [true, true, false],
    ],
  ];

  late List<List<bool>> _currentFigure;
  late int _currentFigureX;
  late int _currentFigureY;
  late Timer _fallingFigureTimer;
  late Timer _acceleratedFallingFigureTimer;
  late Timer _gameTimer;

  late List<List<bool>> board;
  late bool isGameOver;
  late int seconds;
  int get record => _gameStorage.record!;

  void init() {
    seconds = 0;
    isGameOver = false;
    board = List.generate(
        _boardHeight, (_) => List.generate(_boardWidth, (_) => false));
    _spawnNewFigure();
    _startFallingFigureTimer();
    _startGameTimer();
  }

  @override
  void dispose() {
    _fallingFigureTimer.cancel();
    super.dispose();
  }

  void moveCurrentFigureToTheLeft() {
    if (_canBeMovedLeft) {
      _removeFigureFromBoard();
      _currentFigureX--;
      _addFigureToBoard();
    }
  }

  void moveCurrentFigureToTheRight() {
    if (_canBeMovedRight) {
      _removeFigureFromBoard();
      _currentFigureX++;
      _addFigureToBoard();
    }
  }

  void accelerate() {
    _fallingFigureTimer.cancel();
    _acceleratedFallingFigureTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _onFallingTimerTick(),
    );
  }

  void decelerate() {
    _acceleratedFallingFigureTimer.cancel();
    _startFallingFigureTimer();
  }

  void rotate() {
    _removeFigureFromBoard();
    final newFigure = <List<bool>>[];
    for (int x = 0; x < _currentFigure[0].length; x++) {
      final newRow = <bool>[];
      for (int y = _currentFigure.length - 1; y >= 0; y--) {
        newRow.add(_currentFigure[y][x]);
      }
      newFigure.add(newRow);
    }
    final previousFigure = _currentFigure;
    _currentFigure = newFigure;
    if (_isFigureCanBeAdded) {
      _addFigureToBoard();
    } else {
      _currentFigure = previousFigure;
      _addFigureToBoard();
    }
  }

  void _startFallingFigureTimer() {
    _fallingFigureTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _onFallingTimerTick(),
    );
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      seconds++;
    });
  }

  void _onFallingTimerTick() {
    if (_canBeMovedDown) {
      _removeFigureFromBoard();
      _currentFigureY++;
      _addFigureToBoard();
    } else {
      _removeFilledRows();
      _spawnNewFigure();
    }
  }

  bool get _canBeMovedDown {
    for (int x = _currentFigureX;
        x < _currentFigureX + _currentFigure[0].length;
        x++) {
      for (int y = _currentFigureY + _currentFigure.length - 1;
          y >= _currentFigureY;
          y--) {
        if (_currentFigure[y - _currentFigureY][x - _currentFigureX]) {
          if (y + 1 == _boardHeight) return false;
          if (board[y + 1][x]) return false;
          break;
        }
      }
    }
    return true;
  }

  bool get _canBeMovedLeft {
    for (int y = _currentFigureY + _currentFigure.length - 1;
        y >= _currentFigureY;
        y--) {
      for (int x = _currentFigureX;
          x < _currentFigureX + _currentFigure[0].length;
          x++) {
        if (_currentFigure[y - _currentFigureY][x - _currentFigureX]) {
          if (x == 0) return false;
          if (board[y][x - 1]) return false;
          break;
        }
      }
    }
    return true;
  }

  bool get _canBeMovedRight {
    for (int y = _currentFigureY + _currentFigure.length - 1;
        y >= _currentFigureY;
        y--) {
      for (int x = _currentFigureX + _currentFigure[0].length - 1;
          x >= 0;
          x--) {
        if (_currentFigure[y - _currentFigureY][x - _currentFigureX]) {
          if (x + 1 == _boardWidth) return false;
          if (board[y][x + 1]) return false;
          break;
        }
      }
    }
    return true;
  }

  void _spawnNewFigure() {
    _currentFigure = _figures[_random.nextInt(_figures.length)];
    _currentFigureX = _boardWidth ~/ 2 - _currentFigure[0].length ~/ 2;
    _currentFigureY = 0;
    if (!_isFigureCanBeAdded) _stopGame();
    _addFigureToBoard();
  }

  void _stopGame() {
    _gameStorage.saveRecord(seconds).then((_) {
      isGameOver = true;
      _gameTimer.cancel();
      _fallingFigureTimer.cancel();
      _acceleratedFallingFigureTimer.cancel();
    });
  }

  void _addFigureToBoard() {
    for (int x = _currentFigureX;
        x < _currentFigureX + _currentFigure[0].length;
        x++) {
      for (int y = _currentFigureY;
          y < _currentFigureY + _currentFigure.length;
          y++) {
        board[y][x] = _currentFigure[y - _currentFigureY]
                [x - _currentFigureX] ||
            board[y][x];
      }
    }
    notifyListeners();
  }

  bool get _isFigureCanBeAdded {
    for (int x = _currentFigureX;
        x < _currentFigureX + _currentFigure[0].length;
        x++) {
      for (int y = _currentFigureY;
          y < _currentFigureY + _currentFigure.length;
          y++) {
        if (_currentFigure[y - _currentFigureY][x - _currentFigureX] &&
            board[y][x]) {
          return false;
        }
      }
    }
    return true;
  }

  void _removeFigureFromBoard() {
    for (int x = _currentFigureX;
        x < _currentFigureX + _currentFigure[0].length;
        x++) {
      for (int y = _currentFigureY;
          y < _currentFigureY + _currentFigure.length;
          y++) {
        if (_currentFigure[y - _currentFigureY][x - _currentFigureX]) {
          board[y][x] = false;
        }
      }
    }
    notifyListeners();
  }

  void _removeFilledRows() {
    final newBoard = List.generate(
      _boardHeight,
      (_) => List.generate(_boardWidth, (_) => false),
    );
    int currentRowIndex = _boardHeight - 1;
    for (int y = _boardHeight - 1; y >= 0; y--) {
      if (!board[y].every((el) => el)) {
        newBoard[currentRowIndex] = board[y];
        currentRowIndex--;
      }
    }
    board = newBoard;
    notifyListeners();
  }
}
