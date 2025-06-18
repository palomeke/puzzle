import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tile.dart';
import '../providers/puzzle_provider.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;
  final double size;
  final VoidCallback onTap;
  final bool highlight;

  const TileWidget({
    Key? key,
    required this.tile,
    required this.size,
    required this.onTap,
    this.highlight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PuzzleProvider>(context);

    // Imagen: cortar fotografía según posición original (correctIndex)
    if (!tile.isNumber && !tile.isEmpty) {
      final grid = provider.gridSize;
      final row = tile.correctIndex ~/ grid;
      final col = tile.correctIndex % grid;
      final boardSize = size * grid;

      return GestureDetector(
        onTap: onTap,
        child: ClipRect(
          child: SizedBox(
            width: size,
            height: size,
            child: OverflowBox(
              maxWidth: boardSize,
              maxHeight: boardSize,
              alignment: Alignment(
                (col / (grid - 1)) * 2 - 1,
                (row / (grid - 1)) * 2 - 1,
              ),
              child: tile.imageFile != null
                  ? Image.file(
                      tile.imageFile!,
                      width: boardSize,
                      height: boardSize,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      tile.imagePath!,
                      width: boardSize,
                      height: boardSize,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      );
    }

    // Modo numérico: mostrar número y resaltado
    return GestureDetector(
      onTap: tile.isEmpty ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: tile.isEmpty
              ? Colors.transparent
              : (highlight ? Colors.blueAccent : Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: highlight
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ]
              : [],
        ),
        width: size,
        height: size,
        alignment: Alignment.center,
        child: tile.isEmpty
            ? const SizedBox.shrink()
            : Text(
                '${tile.number}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
