// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
import '../models/game_mode.dart';
import '../models/difficulty.dart';
import '../widgets/parallax_background.dart';
import 'game_screen.dart';
import 'image_selection_screen.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({Key? key}) : super(key: key);

  void _startNumeric(BuildContext ctx) {
    final provider = Provider.of<PuzzleProvider>(ctx, listen: false);
    provider.initialize(GameMode.numeric, provider.difficulty);
    Navigator.pushNamed(ctx, GameScreen.routeName);
  }

  void _openImageSelector(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImageSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PuzzleProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          const ParallaxBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        provider.isSoundOn
                            ? Icons.music_note
                            : Icons.music_off,
                        color: Colors.white,
                      ),
                      onPressed: provider.toggleSound,
                    ),
                  ],
                ),
                Hero(
                  tag: 'logo',
                  child: Image.asset('assets/logo.png', height: 360),
                ),
                const SizedBox(height: 40),

                _GameButton(
                  label: 'Modo Numérico',
                  icon: Icons.format_list_numbered,
                  onTap: () => _startNumeric(context),
                ),
                const SizedBox(height: 20),

                _GameButton(
                  label: 'Modo Imagen',
                  icon: Icons.image,
                  onTap: () => _openImageSelector(context),
                ),
                const SizedBox(height: 20),

                _GameButton(
                  label:
                      'Dificultad: ${provider.difficulty.name.toUpperCase()}',
                  icon: Icons.settings,
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => DifficultyDialog(
                      selected: provider.difficulty,
                      onSelected: provider.setDifficulty,
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GameButton({
    required this.label,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DifficultyDialog extends StatelessWidget {
  final Difficulty selected;
  final ValueChanged<Difficulty> onSelected;
  const DifficultyDialog({
    required this.selected,
    required this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar dificultad'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: Difficulty.values.map((d) {
          final name = d.name[0].toUpperCase() + d.name.substring(1);
          return RadioListTile<Difficulty>(
            title: Text(name),
            value: d,
            groupValue: selected,
            onChanged: (val) {
              if (val != null) {
                onSelected(val);
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
