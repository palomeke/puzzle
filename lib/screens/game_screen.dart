import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
import '../models/difficulty.dart';
import '../screens/victory_screen.dart';
import '../widgets/tile_widget.dart';

class GameScreen extends StatelessWidget {
  static const routeName = '/game';
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PuzzleProvider>(
      builder: (ctx, provider, _) {
        if (provider.isVictory) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(ctx, VictoryScreen.routeName);
          });
        }

        final size = MediaQuery.of(ctx).size;
        const padding = 24.0;
        final boardSize =
            (size.width < size.height ? size.width : size.height) - padding * 2;
        final tileSize = boardSize / provider.gridSize;

        final sorted = provider.tiles.toList()
          ..sort((a, b) => a.currentIndex.compareTo(b.currentIndex));

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(ctx),
            ),
            title: Row(
              children: [
                Text(
                  'Tiempo: ${provider.elapsed.toString().split('.').first}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 16),
                Text(
                  'Mov: ${provider.moveCount}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Image.asset(
                'assets/background/app_background.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.suggestion.isEmpty
                          ? 'Sugerencia: -'
                          : 'Sugerencia: ${provider.suggestion.join(', ')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: Container(
                    width: boardSize,
                    height: boardSize,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white54, width: 1.5),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: provider.gridSize,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: sorted.length,
                      itemBuilder: (_, i) {
                        final tile = sorted[i];
                        return TileWidget(
                          tile: tile,
                          size: tileSize,
                          onTap: () => provider.moveTile(tile.currentIndex),
                          highlight:
                              provider.lastTappedIndex == tile.currentIndex,
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Botón de reinicio permanente
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lightbulb, color: Colors.white),
                    label: const Text(
                      'Resolver',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed:
                        provider.isAutoSolving ? null : () => provider.autoSolve(),
                  ),
                ),
              ),
              if (provider.isAutoSolving)
                Positioned(
                  bottom: 130,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.stop, color: Colors.white),
                      label: const Text(
                        'Detener',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: provider.stopAutoSolve,
                    ),
                  ),
                ),
              Positioned(
                bottom: 110,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    const Text(
                      'Velocidad del auto solver',
                      style: TextStyle(color: Colors.white),
                    ),
                    Slider(
                      value: provider.autoSolveSpeed.inMilliseconds.toDouble(),
                      min: 100,
                      max: 1000,
                      divisions: 9,
                      label:
                          '${provider.autoSolveSpeed.inMilliseconds} ms',
                      onChanged: (v) =>
                          provider.setAutoSolveSpeed(v),
                    ),
                  ],
                ),
              ),
              // Botón de reinicio permanente
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Reiniciar juego',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      provider.shuffle();
                      provider.moveCount = 0;
                      provider.elapsed = Duration.zero;
                      provider.isVictory = false;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
