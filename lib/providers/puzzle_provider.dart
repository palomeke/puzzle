import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/tile.dart';
import '../models/game_mode.dart';
import '../models/difficulty.dart';

class PuzzleProvider extends ChangeNotifier {
  List<Tile> tiles = [];
  int gridSize = 3;
  int moveCount = 0;
  bool isSoundOn = true;
  bool isVibrationOn = true;
  bool isDarkMode = false;
  Difficulty difficulty = Difficulty.medium;
  GameMode mode = GameMode.numeric;

  Timer? _timer;
  Duration elapsed = Duration.zero;
  bool isTimerRunning = false;
  bool isVictory = false;
  int? lastTappedIndex;

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
    final indices = List<int>.generate(tiles.length, (i) => i);
    final rand = Random();
    do {
      indices.shuffle(rand);
    } while (!_isSolvable(indices));
    for (var i = 0; i < tiles.length; i++) {
      tiles[i] = tiles[i].copyWith(currentIndex: indices[i]);
    }
    notifyListeners();
  }

  bool _isSolvable(List<int> perm) {
    var inv = 0;
    for (var i = 0; i < perm.length; i++) {
      for (var j = i + 1; j < perm.length; j++) {
        if (perm[i] != perm.length - 1 &&
            perm[j] != perm.length - 1 &&
            perm[i] > perm[j])
          inv++;
      }
    }
    if (gridSize.isOdd) return inv.isEven;
    final row = perm.indexOf(perm.length - 1) ~/ gridSize;
    return (inv + row).isOdd;
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

  void moveTile(int idx) {
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
