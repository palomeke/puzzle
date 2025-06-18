import 'package:flutter/material.dart';
import '../models/difficulty.dart';

/// Diálogo para seleccionar la dificultad del puzzle.
class DifficultyDialog extends StatelessWidget {
  final Difficulty selected;
  final ValueChanged<Difficulty> onSelected;

  const DifficultyDialog({
    Key? key,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar dificultad'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: Difficulty.values.map((d) {
          final name = d.toString().split('.').last;
          final label = name[0].toUpperCase() + name.substring(1);
          return RadioListTile<Difficulty>(
            title: Text(label),
            value: d,
            groupValue: selected,
            onChanged: (val) {
              if (val != null) {
                onSelected(val);
                Navigator.of(context).pop();
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
