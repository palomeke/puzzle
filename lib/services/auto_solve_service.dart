import 'dart:collection';
import 'package:collection/collection.dart';
import '../models/tile.dart';

/// Nodo interno para A*.
class _Node {
  final List<int> state;
  final List<int> moves;
  final int g;
  final int h;
  int get f => g + h;
  _Node(this.state, this.moves, this.g, this.h);
}

/// Servicio que implementa A* para solucionar el puzzle numérico.
class AutoSolveService {
  final int gridSize;
  late final List<int> goalState;

  AutoSolveService(this.gridSize) {
    final size = gridSize * gridSize;
    goalState = List<int>.generate(size, (i) => (i + 1) % size);
  }

  /// Calcula la distancia Manhattan de un estado.
  int _manhattan(List<int> state) {
    var dist = 0;
    for (var i = 0; i < state.length; i++) {
      final val = state[i];
      if (val == 0) continue;
      final correctIndex = val - 1;
      final r1 = i ~/ gridSize, c1 = i % gridSize;
      final r2 = correctIndex ~/ gridSize, c2 = correctIndex % gridSize;
      dist += (r1 - r2).abs() + (c1 - c2).abs();
    }
    return dist;
  }

  /// Resuelve usando A* y devuelve la lista de identificadores movidos.
  ///
  /// Cada ficha se representa por su `number` en modo numérico o por su
  /// índice correcto en modo imagen. El espacio vacío se representa con 0.
  Future<List<int>> solve(List<Tile> initialTiles) async {
    final sorted = [...initialTiles]
      ..sort((a, b) => a.currentIndex.compareTo(b.currentIndex));
    final start = sorted
        .map((t) => t.isEmpty ? 0 : (t.number ?? t.correctIndex + 1))
        .toList();
    if (ListEquality().equals(start, goalState)) return [];

    final open = PriorityQueue<_Node>((a, b) => a.f.compareTo(b.f));
    final closed = <String>{};

    open.add(_Node(start, [], 0, _manhattan(start)));

    while (open.isNotEmpty) {
      final current = open.removeFirst();
      final key = current.state.join(',');
      if (closed.contains(key)) continue;
      if (ListEquality().equals(current.state, goalState)) {
        return current.moves;
      }
      closed.add(key);

      final zeroIndex = current.state.indexOf(0);
      final r = zeroIndex ~/ gridSize;
      final c = zeroIndex % gridSize;
      final dirs = [
        [r - 1, c],
        [r + 1, c],
        [r, c - 1],
        [r, c + 1],
      ];
      for (final d in dirs) {
        final nr = d[0], nc = d[1];
        if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize) continue;
        final newIndex = nr * gridSize + nc;
        final newState = List<int>.from(current.state);
        newState[zeroIndex] = newState[newIndex];
        newState[newIndex] = 0;
        final newKey = newState.join(',');
        if (closed.contains(newKey)) continue;
        final newMoves = List<int>.from(current.moves)
          ..add(current.state[newIndex]);
        final h = _manhattan(newState);
        open.add(_Node(newState, newMoves, current.g + 1, h));
      }
    }
    return []; // sin solución
  }
}
