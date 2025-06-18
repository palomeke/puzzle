// models/tile.dart
import 'dart:io';

/// Representa una ficha del puzzle, numérica o de imagen.
class Tile {
  final int currentIndex;
  final int correctIndex;
  final int? number;
  final String? imagePath;
  final File? imageFile;

  Tile._({
    required this.currentIndex,
    required this.correctIndex,
    this.number,
    this.imagePath,
    this.imageFile,
  });

  /// Fábrica para ficha numérica.
  factory Tile.number({
    required int number,
    required int currentIndex,
    required int correctIndex,
  }) {
    return Tile._(
      number: number,
      currentIndex: currentIndex,
      correctIndex: correctIndex,
    );
  }

  /// Fábrica para ficha de imagen.
  factory Tile.image({
    String? imagePath,
    File? imageFile,
    required int currentIndex,
    required int correctIndex,
  }) {
    return Tile._(
      imagePath: imagePath,
      imageFile: imageFile,
      currentIndex: currentIndex,
      correctIndex: correctIndex,
    );
  }

  /// Fábrica para espacio vacío.
  factory Tile.empty({required int currentIndex, required int correctIndex}) {
    return Tile._(currentIndex: currentIndex, correctIndex: correctIndex);
  }

  bool get isEmpty => number == null && imagePath == null && imageFile == null;
  bool get isNumber => number != null;

  /// Crea una copia con nuevo índice actual.
  Tile copyWith({int? currentIndex}) {
    return Tile._(
      number: number,
      imagePath: imagePath,
      imageFile: imageFile,
      currentIndex: currentIndex ?? this.currentIndex,
      correctIndex: correctIndex,
    );
  }
}
