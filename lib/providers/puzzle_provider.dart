import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/tile.dart';
import '../models/game_mode.dart';
import '../models/difficulty.dart';
import '../services/auto_solve_service.dart';

class PuzzleProvider extends ChangeNotifier {
  List<Tile> tiles = [];
  int gridSize = 3;
  int moveCount = 0;
  bool isSoundOn = true;
  bool isVibrationOn = true;
  bool isDarkMode = false;
  Difficulty difficulty = Difficulty.medium;
  GameMode mode = GameMode.numeric;
  List<int> suggestion = [];

  Timer? _timer;
  Duration elapsed = Duration.zero;
  bool isTimerRunning = false;
  bool isVictory = false;
  int? lastTappedIndex;
  bool isAutoSolving = false;

  Duration autoSolveSpeed = const Duration(milliseconds: 300);
  bool _cancelAutoSolve = false;

  void initialize(
    GameMode selectedMode,
    Difficulty selectedDifficulty, {
    String? imageAsset,
    File? imageFile,
  }) {
    mode = selectedMode;
    setDifficulty(selectedDifficulty);
    moveCount = 0;
    elapsed = Duration.zero;
    isVictory = false;
    _timer?.cancel();
    isTimerRunning = false;
    lastTappedIndex = null;
    isAutoSolving = false;

    final total = gridSize * gridSize;
    tiles = List.generate(total, (index) {
      if (index == total - 1) {
        return Tile.empty(currentIndex: index, correctIndex: index);
      }
      if (mode == GameMode.numeric) {
        return Tile.number(
          number: index + 1,
          currentIndex: index,
          correctIndex: index,
        );
      } else {
        return Tile.image(
          imagePath: imageAsset,
          imageFile: imageFile,
          currentIndex: index,
          correctIndex: index,
        );
      }
    });

    shuffle();
    notifyListeners();
  }

  void shuffle() {
    isAutoSolving = false;
    final indices = List<int>.generate(tiles.length, (i) => i);
    final rand = Random();
    do {
      indices.shuffle(rand);
    } while (!_isSolvable(indices) || _isSolved(indices));
    for (var i = 0; i < tiles.length; i++) {
      tiles[i] = tiles[i].copyWith(currentIndex: indices[i]);
    }
    notifyListeners();
    updateSuggestion();
  }

  bool _isSolvable(List<int> positions) {
    final n = positions.length;
    final board = List<int>.filled(n, 0);
    for (var tile = 0; tile < n; tile++) {
      board[positions[tile]] = tile;
    }

    var inv = 0;
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        if (board[i] != n - 1 && board[j] != n - 1 && board[i] > board[j]) {
          inv++;
        }
      }
    }

    if (gridSize.isOdd) return inv.isEven;
    final row = board.indexOf(n - 1) ~/ gridSize;
    return (inv + row).isOdd;
  }

  bool _isSolved(List<int> perm) {
    for (var i = 0; i < perm.length; i++) {
      if (perm[i] != i) return false;
    }
    return true;
  }

  void startTimer() {
    if (isTimerRunning) return;
    isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    isTimerRunning = false;
  }

  void moveTile(int idx, [bool fromAuto = false]) {
    if (isAutoSolving && !fromAuto) return;
    lastTappedIndex = idx;
    final tile = tiles.firstWhere((t) => t.currentIndex == idx);
    final empty = tiles.firstWhere((t) => t.isEmpty);
    if (_canSwap(tile.currentIndex, empty.currentIndex)) {
      final updatedTile = tile.copyWith(currentIndex: empty.currentIndex);
      final updatedEmpty = empty.copyWith(currentIndex: tile.currentIndex);
      tiles[tiles.indexOf(tile)] = updatedTile;
      tiles[tiles.indexOf(empty)] = updatedEmpty;
      moveCount++;
      if (!isTimerRunning) startTimer();
      notifyListeners();
      _checkVictory();
      if (!fromAuto) {
        updateSuggestion();
      }
    } else {
      notifyListeners();
    }
  }

  bool _canSwap(int a, int b) {
    final r1 = a ~/ gridSize, c1 = a % gridSize;
    final r2 = b ~/ gridSize, c2 = b % gridSize;
    return (r1 == r2 && (c1 - c2).abs() == 1) ||
        (c1 == c2 && (r1 - r2).abs() == 1);
  }

  void _checkVictory() {
    if (tiles.every((t) => t.currentIndex == t.correctIndex)) {
      isVictory = true;
      isAutoSolving = false;
      _cancelAutoSolve = false;
      stopTimer();
      notifyListeners();
    }
  }

  void toggleSound() {
    isSoundOn = !isSoundOn;
    notifyListeners();
  }

  void toggleVibration() {
    isVibrationOn = !isVibrationOn;
    notifyListeners();
  }


  Future<void> updateSuggestion() async {
    final solver = AutoSolveService(gridSize);
    final moves = await solver.solve(tiles);
    suggestion = moves.isNotEmpty ? [moves.first] : [];
    notifyListeners();
  }

  /// Resuelve el puzzle automáticamente.
  ///
  /// Nota: en modo [Difficulty.hard] (5x5) el algoritmo puede agotar la
  /// memoria disponible y la aplicación se cierra de forma inesperada.
  Future<void> autoSolve() async {
    if (isAutoSolving) return;
    if (difficulty == Difficulty.hard) {
      // A* no es viable para 5x5; evitar bloqueo de la app
      return;
    }
    isAutoSolving = true;
    _cancelAutoSolve = false;

  Future<void> autoSolve() async {
    if (isAutoSolving) return;
    isAutoSolving = true;

    notifyListeners();

    final solver = AutoSolveService(gridSize);
    final moves = await solver.solve(tiles);
    for (final id in moves) {

      if (_cancelAutoSolve) break;
      final tile =
          tiles.firstWhere((t) => (t.number ?? t.correctIndex + 1) == id);
      moveTile(tile.currentIndex, true);
      if (_cancelAutoSolve) break;
      await Future.delayed(autoSolveSpeed);
    }

    isAutoSolving = false;
    _cancelAutoSolve = false;
    await updateSuggestion();
    notifyListeners();
  }

  void setAutoSolveSpeed(double ms) {
    autoSolveSpeed = Duration(milliseconds: ms.round());
    notifyListeners();
  }

  void stopAutoSolve() {
    _cancelAutoSolve = true;
  }

=======
      final tile =
          tiles.firstWhere((t) => (t.number ?? t.correctIndex + 1) == id);
      moveTile(tile.currentIndex, true);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    isAutoSolving = false;
    notifyListeners();
  }

  void setDifficulty(Difficulty d) {
    difficulty = d;
    switch (d) {
      case Difficulty.easy:
        gridSize = 2;
        break;
      case Difficulty.medium:
        gridSize = 3;
        break;
      case Difficulty.hard:
        gridSize = 5;
        break;
    }
    notifyListeners();
  }
}
