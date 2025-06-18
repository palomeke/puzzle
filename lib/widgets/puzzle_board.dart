import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
import '../models/tile.dart';

class PuzzleBoard extends StatelessWidget {
  final int gridSize;
  final List<Tile> tiles;
  final void Function(int) onTileTap;
  final double boardSize;

  const PuzzleBoard({
    Key? key,
    required this.gridSize,
    required this.tiles,
    required this.onTileTap,
    required this.boardSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PuzzleProvider>(context);
    final tileSize = boardSize / gridSize;

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: tiles.map((tile) {
          if (tile.isEmpty) return const SizedBox.shrink();

          final position = tile.currentIndex;
          final row = position ~/ gridSize;
          final col = position % gridSize;
          final isTapped = provider.lastTappedIndex == tile.currentIndex;

          return AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: row * tileSize,
            left: col * tileSize,
            child: GestureDetector(
              onTap: () => onTileTap(tile.currentIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isTapped ? tileSize * 1.05 : tileSize,
                height: isTapped ? tileSize * 1.05 : tileSize,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isTapped
                      ? [BoxShadow(color: Colors.black26, blurRadius: 8)]
                      : [],
                ),
                alignment: Alignment.center,
                child: tile.isNumber
                    ? Text(
                        '${tile.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          tile.imagePath!,
                          width: tileSize,
                          height: tileSize,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
